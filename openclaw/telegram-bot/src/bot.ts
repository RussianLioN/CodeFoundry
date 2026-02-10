// @ts-nocheck
/**
 * OpenClaw Telegram Bot
 * Main bot implementation
 */

import TelegramBot from 'node-telegram-bot-api';
import { TelegramUser, CommandContext } from './types';
import { SessionManager } from './session-manager';
import { GatewayClient } from './gateway-client';
import { logger } from './utils/logger';
import { commands } from './commands';

// Global instances
let sessionManager: SessionManager;
let gatewayClient: GatewayClient;
let bot: TelegramBot;

// Export getters for use in commands
export function getGatewayClient(): GatewayClient {
  return gatewayClient;
}

export function getBot(): TelegramBot {
  return bot;
}

/**
 * Initialize bot
 */
async function initializeBot() {
  // Validate environment
  const token = process.env.TELEGRAM_BOT_TOKEN;
  if (!token) {
    throw new Error('TELEGRAM_BOT_TOKEN is required');
  }

  const gatewayUrl = process.env.GATEWAY_URL || 'ws://localhost:18789';
  const sessionTimeout = parseInt(process.env.SESSION_TIMEOUT || '3600000');

  // Initialize session manager
  sessionManager = new SessionManager(sessionTimeout);
  (global as any).sessionManager = sessionManager;

  // Initialize Gateway client
  gatewayClient = new GatewayClient(gatewayUrl);

  // Connect to Gateway
  try {
    await gatewayClient.connect();
    logger.info('Connected to Gateway successfully');
  } catch (error) {
    logger.warn('Failed to connect to Gateway, will retry in background:', error);
  }

  // Initialize Telegram bot
  bot = new TelegramBot(token, { polling: true });

  // Set up command handlers
  setupCommandHandlers();

  // Set up message handler for non-command messages
  bot.on('message', handleNonCommandMessage);

  // Set up error handlers
  bot.on('polling_error', (error) => {
    logger.error('Telegram polling error:', error);
  });

  // Graceful shutdown
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);

  logger.info('OpenClaw Telegram Bot started successfully');
  logger.info(`Session timeout: ${sessionTimeout}ms`);
  logger.info(`Gateway URL: ${gatewayUrl}`);
}

/**
 * Set up command handlers
 */
function setupCommandHandlers() {
  for (const [command, handler] of Object.entries(commands)) {
    bot.onText(new RegExp(`^${command}`), async (msg, match) => {
      await handleCommand(msg, match![0] || command, handler);
    });
  }

  logger.info(`Registered ${Object.keys(commands).length} commands`);
}

/**
 * Handle command
 */
async function handleCommand(
  msg: TelegramBot.Message,
  command: string,
  handler: (ctx: CommandContext) => Promise<string | void>
) {
  const chatId = msg.chat.id;

  try {
    // Get or create session
    const user = extractUser(msg);
    const session = sessionManager.getSession(user);

    // Extract arguments (remove command from message text)
    const text = msg.text || '';
    const args = text
      .replace(command, '')
      .trim()
      .split(/\s+/)
      .filter((arg) => arg.length > 0);

    // Build command context
    const ctx: CommandContext = {
      user,
      session,
      args,
      timestamp: new Date(),
    };

    // Send typing action
    await bot.sendChatAction(chatId, 'typing');

    // Execute command
    const response = await handler(ctx);

    // Send response (plain text, no Markdown)
    if (response) {
      await bot.sendMessage(chatId, response);
    }
  } catch (error) {
    logger.error(`Error handling command ${command}:`, error);
    await bot.sendMessage(
      chatId,
      `Error: ${error instanceof Error ? error.message : 'Unknown error'}`
    );
  }
}

/**
 * Handle non-command messages (natural language)
 */
async function handleNonCommandMessage(msg: TelegramBot.Message) {
  // Ignore messages without text
  if (!msg.text) return;

  // Ignore commands (they're handled separately)
  if (msg.text.startsWith('/')) return;

  const chatId = msg.chat.id;
  const text = msg.text;

  try {
    // Get user and session
    const user = extractUser(msg);
    const session = sessionManager.getSession(user);

    // Check if Gateway is connected
    if (!gatewayClient.connected()) {
      await bot.sendMessage(
        chatId,
        '⏳ *Gateway не подключен*\n\nПопробуйте позже или используйте /status для проверки.',
        { parse_mode: 'Markdown' }
      );
      return;
    }

    // Send typing action
    await bot.sendChatAction(chatId, 'typing');

    // Forward to Gateway for intent parsing
    logger.info(`Forwarding message to Gateway: "${text}"`);

    const response = await gatewayClient.sendMessageWithProgress(
      {
        type: 'chat',
        content: text,
        userId: user.id.toString(),
      },
      async (update) => {
        // Progress update - send to user
        const progress = Math.round(update.progress || 0);
        logger.info(`Progress update: ${progress}% - ${update.message}`);
        await bot.sendMessage(
          chatId,
          `${getProgressEmoji(progress)} ${update.message}\nПрогресс: ${progress}%`,
          { parse_mode: 'Markdown' }
        );
      },
      session.sessionId
    );

    logger.info(`Received response from Gateway: type=${response.type}, has content=${!!response.content}, has error=${!!response.error}`);

    if (response.error) {
      await bot.sendMessage(
        chatId,
        `❌ *Ошибка*\n\n${response.error}`,
        { parse_mode: 'Markdown' }
      );
      return;
    }

    // Handle different response types
    if (response.type === 'question') {
      // Handle question/clarification request
      const question = response.data?.question || response.content || 'Уточните запрос';
      let message = `❓ *Вопрос*\n\n${question}`;

      if (response.data?.options && Array.isArray(response.data.options)) {
        message += '\n\n*Варианты:*\n';
        response.data.options.forEach((opt: string, i: number) => {
          message += `${i + 1}. ${opt}\n`;
        });
      }

      await bot.sendMessage(chatId, message, { parse_mode: 'Markdown' });
      return;
    }

    // Send final response
    if (response.content) {
      await bot.sendMessage(chatId, response.content, { parse_mode: 'Markdown' });
    } else if (response.data) {
      // Format data as response
      await bot.sendMessage(
        chatId,
        `✅ *Готово!*\n\n\`\`\`\n${JSON.stringify(response.data, null, 2)}\n\`\`\``,
        { parse_mode: 'Markdown' }
      );
    }
  } catch (error) {
    logger.error('Error handling non-command message:', error);
    await bot.sendMessage(
      chatId,
      `❌ *Произошла ошибка*\n\n${error instanceof Error ? error.message : 'Неизвестная ошибка'}`,
      { parse_mode: 'Markdown' }
    );
  }
}

/**
 * Extract user from message
 */
function extractUser(msg: TelegramBot.Message): TelegramUser {
  return {
    id: msg.from!.id,
    username: msg.from!.username,
    first_name: msg.from!.first_name,
    last_name: msg.from!.last_name,
    language_code: msg.from!.language_code,
  };
}

/**
 * Get progress emoji
 */
function getProgressEmoji(progress: number): string {
  if (progress < 20) return '🌱';
  if (progress < 40) return '🌿';
  if (progress < 60) return '🔨';
  if (progress < 80) return '⚡';
  return '✅';
}

/**
 * Graceful shutdown
 */
async function shutdown() {
  logger.info('Shutting down gracefully...');

  // Stop bot
  if (bot) {
    bot.stopPolling();
    logger.info('Stopped bot polling');
  }

  // Disconnect from Gateway
  if (gatewayClient) {
    gatewayClient.disconnect();
    logger.info('Disconnected from Gateway');
  }

  process.exit(0);
}

// Start bot
initializeBot().catch((error) => {
  logger.error('Failed to initialize bot:', error);
  process.exit(1);
});

export { initializeBot, sessionManager, gatewayClient };
