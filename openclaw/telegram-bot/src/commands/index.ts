// @ts-nocheck
/**
 * Command handlers registry
 */

import { CommandHandler } from '../types';
import { startCommand } from './start';
import { helpCommand } from './help';
import { newCommand } from './new';
import { statusCommand } from './status';

export const commands: Record<string, CommandHandler> = {
  '/start': startCommand,
  '/help': helpCommand,
  '/new': newCommand,
  '/status': statusCommand,
};

// Command descriptions for help
export const commandDescriptions: Record<string, string> = {
  '/start': 'Начать работу с ботом',
  '/help': 'Показать справку',
  '/new': 'Создать новый проект',
  '/status': 'Показать статус системы',
};

export default commands;
