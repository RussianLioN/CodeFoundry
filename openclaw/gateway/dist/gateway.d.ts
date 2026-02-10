#!/usr/bin/env node
/**
 * OpenClaw Gateway - WebSocket Server v2.0
 *
 * AI-first interface for CodeFoundry project management.
 * Orchestrates commands to Claude Code via Command Protocol v1.0.
 *
 * Architecture:
 * - User Request → Command Generator (AI) → Command Request (JSON)
 * - Command Request → Command Executor → CLI Bridge → Claude Code
 * - Claude Code → CLI Bridge → Command Response (JSON) → User
 *
 * @see https://github.com/RussianLioN/CodeFoundry
 * @see docs/commands/PROTOCOL-v1.md
 * @see docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md
 */
import { OllamaClient } from './ollama-client';
import { CommandGenerator } from './command-generator';
import { CommandExecutor } from './command-executor';
declare class OpenClawGateway {
    private wss;
    private httpServer;
    private healthServer;
    private sessions;
    private workspace;
    private agentTemplatesDir;
    private ollama;
    private commandGenerator;
    private commandExecutor;
    constructor(config: {
        port?: number;
        host?: string;
        workspace?: string;
        ollamaClient?: OllamaClient;
        commandGenerator?: CommandGenerator;
        commandExecutor?: CommandExecutor;
    });
    /**
     * Setup WebSocket event handlers
     */
    private setupWebSocketHandlers;
    /**
     * Handle new WebSocket connection
     */
    private handleConnection;
    /**
     * Handle WebSocket message
     */
    private handleMessage;
    /**
     * Handle chat message (v2.0)
     *
     * New flow:
     * 1. Check for basic commands (help, exit)
     * 2. Generate Command Request from NLP
     * 3. Execute via CLI Bridge
     */
    private handleChat;
    /**
     * Parse user intent from natural language
     */
    private parseIntent;
    /**
     * Parse intent using AI (Ollama)
     */
    private parseWithAI;
    /**
     * Execute parsed intent
     */
    private executeIntent;
    /**
     * Execute: Create Project
     */
    private executeCreateProject;
    /**
     * Execute: Generate Agents
     */
    private executeGenerateAgents;
    /**
     * Execute: Deploy
     */
    private executeDeploy;
    /**
     * Stream progress to WebSocket client
     */
    private streamProgress;
    /**
     * Get WebSocket connection by session ID
     */
    private getWebSocket;
    /**
     * Execute shell command and stream output
     */
    private executeCommand;
    /**
     * Get status text
     */
    private getStatus;
    /**
     * Get help text
     */
    private getHelpText;
    /**
     * Extract username from request (if available)
     */
    private getUsernameFromReq;
    /**
     * Generate unique session ID
     */
    private generateSessionId;
    /**
     * Send message to WebSocket client
     */
    private sendMessage;
    /**
     * Handle WebSocket error
     */
    private handleError;
    /**
     * Handle connection close
     */
    private handleClose;
    /**
     * Get session statistics
     */
    getStats(): {
        totalSessions: number;
        activeSessions: number;
        avgDuration: number;
    };
    /**
     * Shutdown gateway
     */
    shutdown(): void;
}
export { OpenClawGateway };
//# sourceMappingURL=gateway.d.ts.map