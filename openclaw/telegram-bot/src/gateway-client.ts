// @ts-nocheck
/**
 * Gateway Client - WebSocket connection to OpenClaw Gateway
 */

import WebSocket from 'ws';
import { v4 as uuidv4 } from 'uuid';
import { GatewayMessage, GatewayResponse, ProgressUpdate, CommandProtocolRequest } from './types';
import { logger } from './utils/logger';

export class GatewayClient {
  private ws: WebSocket | null = null;
  private url: string;
  private reconnectInterval: number;
  private maxReconnectAttempts: number;
  private reconnectAttempts: number = 0;
  private messageHandlers: Map<string, (response: GatewayResponse) => void>;
  private progressHandlers: Map<string, (update: ProgressUpdate) => void>;
  private isConnected: boolean = false;

  constructor(
    url: string = 'ws://localhost:18789',
    reconnectInterval: number = 5000,
    maxReconnectAttempts: number = 10
  ) {
    this.url = url;
    this.reconnectInterval = reconnectInterval;
    this.maxReconnectAttempts = maxReconnectAttempts;
    this.messageHandlers = new Map();
    this.progressHandlers = new Map();
  }

  /**
   * Connect to Gateway
   */
  connect(): Promise<void> {
    return new Promise((resolve, reject) => {
      logger.info(`Connecting to Gateway at ${this.url}`);

      this.ws = new WebSocket(this.url);

      this.ws.on('open', () => {
        logger.info('Connected to Gateway');
        this.isConnected = true;
        this.reconnectAttempts = 0;
        resolve();
      });

      this.ws.on('message', (data: string) => {
        this.handleMessage(data);
      });

      this.ws.on('error', (error) => {
        logger.error('Gateway WebSocket error:', error);
        reject(error);
      });

      this.ws.on('close', () => {
        logger.warn('Gateway connection closed');
        this.isConnected = false;
        this.attemptReconnect();
      });
    });
  }

  /**
   * Attempt to reconnect
   */
  private attemptReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      logger.error('Max reconnection attempts reached');
      return;
    }

    this.reconnectAttempts++;
    logger.info(
      `Reconnecting to Gateway... (attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts})`
    );

    setTimeout(() => {
      this.connect().catch((error) => {
        logger.error('Reconnection failed:', error);
      });
    }, this.reconnectInterval);
  }

  /**
   * Handle incoming message from Gateway
   */
  private handleMessage(data: string): void {
    try {
      const response: GatewayResponse = JSON.parse(data);

      logger.info('[GATEWAY_CLIENT] Received message type:', response.type, 'sessionId:', response.sessionId, 'has content:', !!response.content);

      // Handle different message types
      switch (response.type) {
        case 'progress':
          this.handleProgress(response);
          break;
        case 'complete':
          this.handleComplete(response);
          break;
        case 'error':
          this.handleError(response);
          break;
        default:
          // Regular response
          if (response.sessionId) {
            const handler = this.messageHandlers.get(response.sessionId);
            if (handler) {
              handler(response);
              this.messageHandlers.delete(response.sessionId);
            }
          }
      }
    } catch (error) {
      logger.error('Failed to parse Gateway message:', error);
    }
  }

  /**
   * Handle progress update
   */
  private handleProgress(response: GatewayResponse): void {
    if (response.sessionId) {
      const handler = this.progressHandlers.get(response.sessionId);
      if (handler && response.data) {
        handler(response.data as ProgressUpdate);
      }
    }
  }

  /**
   * Handle complete response
   */
  private handleComplete(response: GatewayResponse): void {
    if (response.sessionId) {
      const handler = this.messageHandlers.get(response.sessionId);
      if (handler) {
        handler(response);
        this.messageHandlers.delete(response.sessionId);
      }
      // Also clear progress handler
      this.progressHandlers.delete(response.sessionId);
    }
  }

  /**
   * Handle error response
   */
  private handleError(response: GatewayResponse): void {
    logger.error('Gateway error:', response.error);

    if (response.sessionId) {
      const handler = this.messageHandlers.get(response.sessionId);
      if (handler) {
        handler(response);
        this.messageHandlers.delete(response.sessionId);
      }
      this.progressHandlers.delete(response.sessionId);
    }
  }

  /**
   * Send message to Gateway
   */
  async sendMessage(
    message: GatewayMessage,
    sessionId?: string
  ): Promise<GatewayResponse> {
    return new Promise((resolve, reject) => {
      if (!this.isConnected || !this.ws) {
        reject(new Error('Not connected to Gateway'));
        return;
      }

      // Generate session ID if not provided
      const sid = sessionId || uuidv4();
      message.sessionId = sid;

      // Set up response handler
      this.messageHandlers.set(sid, (response) => {
        if (response.error) {
          reject(new Error(response.error));
        } else {
          resolve(response);
        }
      });

      // Send message
      this.ws!.send(JSON.stringify(message));
      logger.debug('Sent to Gateway:', message);
    });
  }

  /**
   * Send message with progress callback
   */
  async sendMessageWithProgress(
    message: GatewayMessage,
    onProgress: (update: ProgressUpdate) => void,
    sessionId?: string
  ): Promise<GatewayResponse> {
    const sid = sessionId || uuidv4();

    // Set up progress handler
    this.progressHandlers.set(sid, onProgress);

    return this.sendMessage(message, sid);
  }

  /**
   * Send chat message
   */
  async sendChat(content: string, userId?: string): Promise<GatewayResponse> {
    return this.sendMessage({
      type: 'chat',
      content,
      userId,
    });
  }

  /**
   * Send Command Protocol v1.0 JSON request
   */
  async sendJSON(
    commandRequest: CommandProtocolRequest,
    onProgress?: (update: ProgressUpdate) => void,
    sessionId?: string
  ): Promise<GatewayResponse> {
    const sid = sessionId || uuidv4();

    // Set up progress handler if provided
    if (onProgress) {
      this.progressHandlers.set(sid, onProgress);
    }

    // Convert Command Protocol request to Gateway message
    const gatewayMessage: GatewayMessage = {
      type: 'chat',
      content: JSON.stringify(commandRequest),
      sessionId: sid,
    };

    return this.sendMessage(gatewayMessage, sid);
  }

  /**
   * Ping Gateway
   */
  async ping(): Promise<boolean> {
    try {
      await this.sendMessage({ type: 'ping' });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Check connection status
   */
  connected(): boolean {
    return this.isConnected && this.ws?.readyState === WebSocket.OPEN;
  }

  /**
   * Disconnect from Gateway
   */
  disconnect(): void {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
      this.isConnected = false;
      logger.info('Disconnected from Gateway');
    }
  }
}
