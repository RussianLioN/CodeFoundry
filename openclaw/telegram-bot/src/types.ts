// @ts-nocheck
/**
 * Type definitions for OpenClaw Telegram Bot
 */

// Telegram User
export interface TelegramUser {
  id: number;
  username?: string;
  first_name: string;
  last_name?: string;
  language_code?: string;
  is_bot?: boolean;
}

// Session context
export interface BotSession {
  sessionId: string;
  userId: number;
  username?: string;
  startedAt: Date;
  lastActivity: Date;
  currentProject?: string;
  currentTask?: string;
  context: Record<string, any>;
  gatewayConnected: boolean;
  pendingCommand?: string;
}

// Gateway WebSocket message
export interface GatewayMessage {
  type: 'chat' | 'ping' | 'subscribe' | 'progress' | 'complete' | 'error';
  content?: string;
  sessionId?: string;
  userId?: string;
  stage?: string;
  progress?: number;
  message?: string;
  data?: any;
}

// Intent from Gateway
export interface Intent {
  name: string;
  parameters: Record<string, any>;
  confidence: number;
}

// Command context
export interface CommandContext {
  user: TelegramUser;
  session: BotSession;
  args: string[];
  timestamp: Date;
}

// Command handler
export type CommandHandler = (ctx: CommandContext) => Promise<string | void>;

// Progress update
export interface ProgressUpdate {
  stage: string;
  progress: number;
  message: string;
}

// Project info
export interface ProjectInfo {
  name: string;
  type: string;
  language: string;
  path: string;
  createdAt: Date;
  lastModified?: Date;
}

// Gateway response
export interface GatewayResponse {
  type: string;
  content?: string;
  data?: any;
  error?: string;
  sessionId?: string;
}
