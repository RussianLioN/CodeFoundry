// @ts-nocheck
/**
 * /start command - Initialize bot
 */

import { CommandContext } from '../types';
import { logger } from '../utils/logger';

export async function startCommand(ctx: CommandContext): Promise<string> {
  const { user, session } = ctx;

  logger.info(`User ${user.id} started the bot`);

  // Check if user is authorized
  const authorizedUserIds = process.env.AUTHORIZED_USER_IDS
    ? process.env.AUTHORIZED_USER_IDS.split(',').map((id) => parseInt(id))
    : [];

  // For MVP: Allow all if not configured, or check authorized list
  if (authorizedUserIds.length > 0 && !authorizedUserIds.includes(user.id)) {
    logger.warn(`Unauthorized user ${user.id} attempted to use bot`);
    return `⛔ Извините, у вас нет доступа к этому боту.`;
  }

  // Welcome message
  const welcome = `
🤖 *Добро пожаловать в OpenClaw!*

Это Telegram бот для AI-powered разработки через OpenClaw Gateway.

${user.first_name}, добро пожаловать!

📋 *Доступные команды:*

/help — Показать справку
/new — Создать новый проект
/status — Статус системы

🔗 *Связь с Gateway:* ${session.gatewayConnected ? '✅ Подключен' : '⏳ Ожидание...'}

💡 *Начните работу:*
Попробуйте: \`/new telegram-bot my-bot\`
`;

  return welcome;
}
