// @ts-nocheck
/**
 * /help command - Show help
 */

import { CommandContext } from '../types';
import { commandDescriptions } from './index';

export async function helpCommand(ctx: CommandContext): Promise<string> {
  const { session } = ctx;

  let help = `
📖 *Справка OpenClaw Bot*

🤖 *Что я умею:*

`;

  // List all commands with descriptions
  for (const [cmd, desc] of Object.entries(commandDescriptions)) {
    help += `• \`${cmd}\` — ${desc}\n`;
  }

  help += `
💡 *Примеры использования:*

Создать проект:
\`/new telegram-bot delivery-bot\`
\`/new web-service shop-api --language=typescript\`

Статус системы:
\`/status\`

🔧 *Настройки:*

Шлюз: ${session.gatewayConnected ? '✅ Подключен' : '❌ Отключен'}
Проект: ${session.currentProject || 'Не выбран'}

📚 *Документация:*
Полная документация: github.com/RussianLioN/CodeFoundry

❓ *Нужна помощь?*
Используйте /start для инициализации
`;

  return help;
}
