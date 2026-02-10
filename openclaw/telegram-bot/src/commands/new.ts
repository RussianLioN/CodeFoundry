// @ts-nocheck
/**
 * /new command - Create new project
 */

import { CommandContext, ProgressUpdate } from '../types';
import { logger } from '../utils/logger';

export async function newCommand(ctx: CommandContext): Promise<string> {
  const { user, session, args } = ctx;

  logger.info(`User ${user.id} requested /new with args:`, args);

  // Validate arguments
  if (args.length < 2) {
    return `
⚠️ *Неверный формат команды*

Использование: \`/new [тип] [название] [опции]\n\n\`
*Типы проектов:*
• telegram-bot — Telegram бот
• web-service — Web сервис (REST API)
• ai-agent — AI агент
• fullstack — Full-stack приложение

*Примеры:*
\`/new telegram-bot delivery-bot\`
\`/new web-service shop-api\`
\`/new ai-agent assistant --language=python\`
`;
  }

  const [projectType, projectName, ...options] = args;

  // Validate project type
  const validTypes = ['telegram-bot', 'web-service', 'ai-agent', 'fullstack'];
  if (!validTypes.includes(projectType)) {
    return `❌ *Неверный тип проекта: ${projectType}*\n\nДоступные типы: ${validTypes.join(', ')}`;
  }

  // Check if Gateway is connected
  if (!session.gatewayConnected) {
    return '❌ *Gateway не подключен*\n\nПопробуйте позже или проверьте статус системы: /status';
  }

  // Import GatewayClient dynamically to avoid circular dependency
  const { getGatewayClient } = await import('../bot');
  const gateway = getGatewayClient();

  if (!gateway.connected()) {
    return '❌ *Gateway не подключен*\n\nПопробуйте позже.';
  }

  // Prepare intent message
  const content = `Создай проект ${projectType} ${projectName}`;

  try {
    // Send to Gateway with progress tracking
    const response = await gateway.sendMessageWithProgress(
      {
        type: 'chat',
        content,
        userId: user.id.toString(),
      },
      (update: ProgressUpdate) => {
        // Progress callback - send updates to user
        logger.info(`Progress: ${update.progress}% - ${update.message}`);
        // Note: In real implementation, we'd send this to Telegram
        // For now, we'll accumulate and show at end
      },
      session.sessionId
    );

    if (response.error) {
      logger.error('Gateway error:', response.error);
      return `❌ *Ошибка создания проекта*\n\n${response.error}`;
    }

    // Update session
    const { getCurrentProject, setCurrentProject } = await import('../session-manager');
    const sessionManager = (global as any).sessionManager;
    if (sessionManager) {
      sessionManager.setCurrentProject(user.id, projectName);
    }

    return `
✅ *Проект создан успешно!*

📦 *Проект:* \`${projectName}\`
🏷️ *Тип:* ${projectType}
📁 *Расположение:* \`workspace/projects/${projectName}\`

🎯 *Следующие шаги:*

1. Перейдите в директорию проекта:
   \`cd workspace/projects/${projectName}\`

2. Настройте окружение:
   \`cp .env.example .env\`
   \`nano .env\`  # отредактируйте настройки

3. Установите зависимости:
   \`make install\`  или \`npm install\`

4. Запустите разработку:
   \`make dev\`

💡 *AI агенты готовы:*
Ваша команда теперь включает специализированных AI агентов для разработки!

📚 *Документация:*
Смотрите PROJECT.md в директории проекта
`;

  } catch (error) {
    logger.error('Error creating project:', error);
    return `❌ *Ошибка создания проекта*\n\n${error instanceof Error ? error.message : 'Неизвестная ошибка'}`;
  }
}
