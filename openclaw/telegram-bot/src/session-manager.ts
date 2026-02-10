// @ts-nocheck
/**
 * Session Manager for Telegram Bot
 * Manages user sessions and context
 */

import { v4 as uuidv4 } from 'uuid';
import { BotSession, TelegramUser } from './types';
import { logger } from './utils/logger';

export class SessionManager {
  private sessions: Map<number, BotSession> = new Map();
  private sessionTimeout: number;

  constructor(sessionTimeout: number = 3600000) {
    // Default: 1 hour
    this.sessionTimeout = sessionTimeout;

    // Cleanup expired sessions every 5 minutes
    setInterval(() => this.cleanupExpiredSessions(), 300000);
  }

  /**
   * Get or create session for user
   */
  getSession(user: TelegramUser): BotSession {
    let session = this.sessions.get(user.id);

    if (!session || this.isSessionExpired(session)) {
      session = this.createSession(user);
      this.sessions.set(user.id, session);
      logger.info(`Created new session for user ${user.id}`);
    } else {
      // Update last activity
      session.lastActivity = new Date();
    }

    return session;
  }

  /**
   * Create new session
   */
  private createSession(user: TelegramUser): BotSession {
    return {
      sessionId: uuidv4(),
      userId: user.id,
      username: user.username,
      startedAt: new Date(),
      lastActivity: new Date(),
      context: {},
      gatewayConnected: false,
    };
  }

  /**
   * Check if session is expired
   */
  private isSessionExpired(session: BotSession): boolean {
    const now = Date.now();
    const lastActivity = session.lastActivity.getTime();
    return now - lastActivity > this.sessionTimeout;
  }

  /**
   * Cleanup expired sessions
   */
  private cleanupExpiredSessions(): void {
    let cleaned = 0;

    for (const [userId, session] of this.sessions.entries()) {
      if (this.isSessionExpired(session)) {
        this.sessions.delete(userId);
        cleaned++;
      }
    }

    if (cleaned > 0) {
      logger.info(`Cleaned up ${cleaned} expired sessions`);
    }
  }

  /**
   * Update session context
   */
  updateContext(userId: number, key: string, value: any): void {
    const session = this.sessions.get(userId);
    if (session) {
      session.context[key] = value;
      session.lastActivity = new Date();
    }
  }

  /**
   * Get session context value
   */
  getContext(userId: number, key: string): any {
    const session = this.sessions.get(userId);
    return session?.context[key];
  }

  /**
   * Set current project for session
   */
  setCurrentProject(userId: number, projectName: string): void {
    const session = this.sessions.get(userId);
    if (session) {
      session.currentProject = projectName;
      session.lastActivity = new Date();
      logger.info(`User ${userId} set current project: ${projectName}`);
    }
  }

  /**
   * Get current project for session
   */
  getCurrentProject(userId: number): string | undefined {
    const session = this.sessions.get(userId);
    return session?.currentProject;
  }

  /**
   * Set current task for session
   */
  setCurrentTask(userId: number, task: string): void {
    const session = this.sessions.get(userId);
    if (session) {
      session.currentTask = task;
      session.lastActivity = new Date();
    }
  }

  /**
   * Clear current task
   */
  clearCurrentTask(userId: number): void {
    const session = this.sessions.get(userId);
    if (session) {
      session.currentTask = undefined;
      session.lastActivity = new Date();
    }
  }

  /**
   * Set gateway connection status
   */
  setGatewayConnected(userId: number, connected: boolean): void {
    const session = this.sessions.get(userId);
    if (session) {
      session.gatewayConnected = connected;
      session.lastActivity = new Date();
    }
  }

  /**
   * Delete session (logout)
   */
  deleteSession(userId: number): void {
    this.sessions.delete(userId);
    logger.info(`Deleted session for user ${userId}`);
  }

  /**
   * Get session stats
   */
  getStats(): { totalSessions: number; activeSessions: number } {
    return {
      totalSessions: this.sessions.size,
      activeSessions: Array.from(this.sessions.values()).filter(
        (s) => !this.isSessionExpired(s)
      ).length,
    };
  }

  /**
   * Get all sessions (for admin/debug)
   */
  getAllSessions(): BotSession[] {
    return Array.from(this.sessions.values());
  }
}
