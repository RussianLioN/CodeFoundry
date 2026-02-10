// @ts-nocheck
/**
 * /status command - Show system status
 */

import { CommandContext } from '../types';
import { logger } from '../utils/logger';

export async function statusCommand(ctx: CommandContext): Promise<string> {
  const { user, session } = ctx;

  logger.info(`User ${user.id} requested /status`);

  // Simple test message first
  const status = `Status: OK
Bot is running
Gateway: Connected
User: ${user.id}`;

  return status;
}
