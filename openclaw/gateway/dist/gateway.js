#!/usr/bin/env node
"use strict";
// @ts-nocheck - TODO: Fix type errors (TSFIX-002)
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.OpenClawGateway = void 0;
const ws_1 = require("ws");
const http_1 = require("http");
const path_1 = require("path");
const uuid_1 = require("uuid");
// OpenClaw Modules (v2.0)
const ollama_client_1 = require("./ollama-client");
const command_generator_1 = require("./command-generator");
const command_executor_1 = require("./command-executor");
// Configuration
const GATEWAY_PORT = parseInt(process.env.GATEWAY_PORT || '18789');
const HEALTH_PORT = parseInt(process.env.HEALTH_PORT || '18790');
const GATEWAY_HOST = process.env.GATEWAY_HOST || '0.0.0.0';
// Ollama Cloud API Configuration
const OLLAMA_BASE_URL = process.env.OLLAMA_BASE_URL || 'https://api.ollama.cloud';
const OLLAMA_API_KEY = process.env.OLLAMA_API_KEY;
const OLLAMA_MODEL = process.env.OLLAMA_MODEL || 'gemini-3-flash-preview:cloud';
// ============================================================================
// GATEWAY CLASS
// ============================================================================
class OpenClawGateway {
    wss;
    httpServer;
    healthServer;
    sessions;
    workspace;
    agentTemplatesDir;
    // v2.0: Modular Architecture
    ollama;
    commandGenerator;
    commandExecutor;
    constructor(config) {
        // Configuration
        const port = config.port || GATEWAY_PORT;
        const healthPort = config.healthPort || HEALTH_PORT;
        const host = config.host || GATEWAY_HOST;
        this.workspace = config.workspace || process.cwd();
        this.agentTemplatesDir = (0, path_1.join)(this.workspace, 'openclaw/workspace/agents');
        // v2.0: Initialize modular components
        this.ollama = config.ollamaClient || (0, ollama_client_1.createOllamaClient)();
        this.commandGenerator = config.commandGenerator || (0, command_generator_1.createCommandGenerator)({
            ollamaClient: this.ollama,
        });
        this.commandExecutor = config.commandExecutor || (0, command_executor_1.createCommandExecutor)({
            workspace: this.workspace,
        });
        // Initialize sessions storage
        this.sessions = new Map();
        // Create HTTP server for WebSocket
        this.httpServer = (0, http_1.createServer)((req, res) => {
            res.writeHead(404);
            res.end('Not Found - Use WebSocket connection');
        });
        // Create separate HTTP server for health check
        this.healthServer = (0, http_1.createServer)((req, res) => {
            if (req.url === '/health') {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    status: 'healthy',
                    uptime: process.uptime(),
                    sessions: this.sessions.size,
                    ollama: {
                        baseURL: OLLAMA_BASE_URL,
                        model: this.ollama.getModel(),
                        configured: !!OLLAMA_API_KEY,
                    },
                    executor: this.commandExecutor.getStats(),
                }));
            }
            else {
                res.writeHead(404);
                res.end('Not Found');
            }
        });
        // Create WebSocket server attached to HTTP server
        this.wss = new ws_1.WebSocketServer({
            noServer: true,
            clientTracking: true
        });
        // Handle WebSocket upgrades
        this.httpServer.on('upgrade', (request, socket, head) => {
            this.wss.handleUpgrade(request, socket, head, (ws) => {
                this.wss.emit('connection', ws, request);
            });
        });
        // Start health server first
        this.healthServer.listen(healthPort, host, () => {
            console.log(`[HEALTH] Health check on http://${host}:${healthPort}/health`);
        });
        // Start WebSocket server
        this.httpServer.listen(port, host, () => {
            console.log(`[GATEWAY] v2.0 Running on ws://${host}:${port}`);
            console.log(`[AI] Model: ${this.ollama.getModel()} @ ${OLLAMA_BASE_URL}`);
            console.log(`[AI] API Key: ${OLLAMA_API_KEY ? 'configured' : 'NOT configured (using local fallback)'}`);
            console.log(`[WORKSPACE] ${this.workspace}`);
            console.log(`[CLI Bridge] ${this.commandExecutor.getStats().cliWrapperPath}`);
            console.log('');
        });
        this.setupWebSocketHandlers();
    }
    /**
     * Setup WebSocket event handlers
     */
    setupWebSocketHandlers() {
        this.wss.on('connection', this.handleConnection.bind(this));
        this.wss.on('error', this.handleError.bind(this));
    }
    /**
     * Handle new WebSocket connection
     */
    async handleConnection(ws, req) {
        const sessionId = this.generateSessionId();
        console.log(`[IN] New connection: ${sessionId}`);
        // Create session
        const session = {
            id: sessionId,
            userId: req.socket?.remoteAddress,
            username: this.getUsernameFromReq(req),
            startedAt: new Date(),
            lastActivity: new Date(),
            messages: [],
            context: {
                gatewayVersion: '1.0.0',
                workspace: this.workspace
            },
            currentAgent: 'main',
            currentTask: null,
            projectDir: null
        };
        this.sessions.set(sessionId, session);
        // Send welcome message
        this.sendMessage(ws, {
            type: 'complete',
            sessionId,
            content: `[OpenClaw Gateway] Добро пожаловать!

Я помогу вам управлять CodeFoundry через естественный язык.

Команды:
• "Создай проект [тип] [название]"
• "Сгенерируй агентов для [проекта]"
• "Задеплой на [окружение]"
• "Покажи статус"

Доступные агенты: main, dev, devops, prompt, codefoundry

Для справки: help или "помощь"
Для выхода: exit или "выход"
`
        });
    }
    /**
     * Handle WebSocket message
     */
    async handleMessage(ws, message, session) {
        try {
            session.messages.push(message);
            session.lastActivity = new Date();
            // Log message (in development)
            if (process.env.NODE_ENV === 'development') {
                console.log(`[${session.id}] ${message.type}: ${message.content}`);
            }
            let response;
            switch (message.type) {
                case 'chat':
                    response = await this.handleChat(message, session);
                    break;
                case 'command':
                    response = await this.handleCommand(message, session);
                    break;
                case 'status':
                    response = {
                        type: 'complete',
                        sessionId: session.id,
                        content: `Статус сессии:

Агент: ${session.currentAgent}
Задача: ${session.currentTask || 'нет'}
Сообщений: ${session.messages.length}
Время сессии: ${Math.floor((Date.now() - session.startedAt.getTime()) / 1000)} сек`
                    };
                    break;
                case 'ping':
                    response = {
                        type: 'complete',
                        sessionId: session.id,
                        content: '[PONG] Pong!'
                    };
                    break;
                default:
                    response = {
                        type: 'error',
                        sessionId: session.id,
                        content: `Неизвестный тип сообщения: ${message.type}`
                    };
            }
            // Send response
            this.sendMessage(ws, response);
        }
        catch (error) {
            console.error(`[ERROR] Message handling:`, error);
            this.sendMessage(ws, {
                type: 'error',
                sessionId: session.id,
                content: `Произошла ошибка: ${error.message}`
            });
        }
    }
    /**
     * Handle chat message (v2.0)
     *
     * New flow:
     * 1. Check for basic commands (help, exit)
     * 2. Generate Command Request from NLP
     * 3. Execute via CLI Bridge
     */
    async handleChat(message, session) {
        const content = message.content.trim();
        // Check for basic commands
        const lowerContent = content.toLowerCase();
        if (lowerContent === 'help' || lowerContent === 'помощь') {
            return {
                type: 'complete',
                sessionId: session.id,
                content: this.getHelpText(),
            };
        }
        if (lowerContent === 'exit' || lowerContent === 'выход') {
            return {
                type: 'complete',
                sessionId: session.id,
                content: '[GOODBYE] До свидания! Сессия завершена.'
            };
        }
        try {
            // v2.0: Generate command from NLP
            await this.streamProgress(session, {
                stage: 'parsing',
                progress: 10,
                message: 'Анализирую запрос...'
            });
            const commandRequest = await this.commandGenerator.generateCommand(content, {
                user_id: session.userId,
                session_id: session.id,
            });
            console.log(`[GATEWAY] Generated command: ${commandRequest.command} (id: ${commandRequest.id})`);
            // v2.0: Execute via CLI Bridge
            await this.streamProgress(session, {
                stage: 'executing',
                progress: 30,
                message: `Выполняю команду: ${commandRequest.command}...`
            });
            const commandResponse = await this.commandExecutor.executeWithProgress(commandRequest, (stage, progress, message) => {
                this.streamProgress(session, { stage: stage, progress, message });
            });
            // Return result
            if (commandResponse.status === 'success') {
                return {
                    type: 'complete',
                    sessionId: session.id,
                    content: commandResponse.message || 'Команда выполнена успешно!',
                    data: commandResponse.result,
                };
            }
            else {
                return {
                    type: 'error',
                    sessionId: session.id,
                    content: commandResponse.error?.message || 'Ошибка выполнения команды',
                    data: commandResponse.error,
                };
            }
        }
        catch (error) {
            // Handle ambiguity
            if (error instanceof command_generator_1.AmbiguityError) {
                return {
                    type: 'question',
                    sessionId: session.id,
                    question: error.message,
                    options: error.options,
                };
            }
            // Handle other errors
            console.error('[GATEWAY] Command execution error:', error);
            return {
                type: 'error',
                sessionId: session.id,
                content: `Ошибка: ${error.message}`,
            };
        }
    }
    /**
     * Parse user intent from natural language
     */
    async parseIntent(content) {
        // For now, simple keyword-based routing
        // In production: load intent-parser.md and use Ollama
        const lowerContent = content.toLowerCase();
        // Detect intent category
        let intent = {
            status: 'success',
            category: '',
            confidence: 0,
            parameters: {},
            command: null
        };
        // Detect intent
        if (lowerContent.includes('созда') && lowerContent.includes('проект')) {
            intent.category = 'create_project';
            intent.confidence = 0.8;
            // Extract archetype
            for (const archetype of ['web-service', 'telegram-bot', 'ai-agent', 'fullstack', 'data-pipeline', 'cli-tool', 'microservices', 'presentation']) {
                if (lowerContent.includes(archetype)) {
                    intent.parameters.archetype = archetype;
                    break;
                }
            }
            // Extract name (basic)
            const nameMatch = content.match(/(?:проект|bot|сервис|api|система)\s+["']?([^"']+)["']?/i);
            if (nameMatch) {
                intent.parameters.name = nameMatch[1];
            }
        }
        else if (lowerContent.includes('сгенерируй') && lowerContent.includes('агент')) {
            intent.category = 'generate_agents';
            intent.confidence = 0.8;
            const nameMatch = content.match(/для\s+([\w-]+)/i);
            if (nameMatch) {
                intent.parameters.project_name = nameMatch[1];
            }
        }
        else if (lowerContent.includes('задеплой')) {
            intent.category = 'deploy';
            intent.confidence = 0.9;
            const envMatch = content.match(/(?:на|в)\s+([\w-]+)/i);
            if (envMatch) {
                intent.parameters.environment = envMatch[1];
            }
            intent.parameters.environment = intent.parameters.environment || 'staging';
        }
        else {
            // Try to use AI for parsing
            return await this.parseWithAI(content);
        }
        return intent;
    }
    /**
     * Parse intent using AI (Ollama)
     */
    async parseWithAI(content) {
        try {
            const response = await fetch(`${OLLAMA_BASE_URL}/api/generate`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    model: OLLAMA_MODEL,
                    prompt: `You are an intent parser. Parse the user's request and return JSON.

User request: "${content}"

Return JSON format:
{
  "status": "success" | "ambiguity" | "error",
  "category": "create_project" | "generate_agents" | "deploy" | "status" | "help",
  "confidence": 0.0-1.0,
  "parameters": {},
  "question": "if ambiguous",
  "options": ["option1", "option2"],
  "error": "if error"
}

Categories:
- create_project: Создание нового проекта
- generate_agents: Генерация AI агентов
- deploy: Деплой проекта
- status: Запрос статуса
- help: Запрос помощи

For create_project, extract:
- archetype: web-service, telegram-bot, ai-agent, fullstack, etc.
- name: project name (e.g., "my-bot", "my-api")
- location: optional path (default: ./)

For generate_agents, extract:
- project_name: existing project name

For deploy, extract:
- environment: staging, production
- project_name: optional (default: current)

Return ONLY valid JSON, no explanation text.`,
                    stream: false
                }),
            });
            const text = await response.text();
            return JSON.parse(text);
        }
        catch (error) {
            console.error('AI parsing failed:', error);
            // Fallback to simple routing
            return {
                status: 'ambiguity',
                question: `Не совсем понял. Что вы хотите сделать?

Доступные команды:
• "Создай проект [тип] [имя]"
• "Сгенерируй агентов для [проекта]"
• "Задеплой на [окружение]"
• "Покажи статус"

Попробуйте перефразировать.`,
                options: [
                    'Создать проект',
                    'Сгенерировать агентов',
                    'Задеплой',
                    'Статус'
                ]
            };
        }
    }
    /**
     * Execute parsed intent
     */
    async executeIntent(intent, session) {
        const startTime = Date.now();
        try {
            let result;
            switch (intent.category) {
                case 'create_project':
                    result = await this.executeCreateProject(intent, session);
                    break;
                case 'generate_agents':
                    result = await this.executeGenerateAgents(intent, session);
                    break;
                case 'deploy':
                    result = await this.executeDeploy(intent, session);
                    break;
                case 'status':
                    result = this.getStatus(session);
                    break;
                default:
                    result = {
                        success: false,
                        error: `Неизвестная категория: ${intent.category}`
                    };
            }
            const duration = Date.now() - startTime;
            return {
                type: 'complete',
                sessionId: session.id,
                agent: session.currentAgent,
                content: result.message || 'Готово!',
                data: result
            };
        }
        catch (error) {
            return {
                type: 'error',
                sessionId: session.id,
                content: `[ERROR] Ошибка: ${error.message}`
            };
        }
    }
    /**
     * Execute: Create Project
     */
    async executeCreateProject(intent, session) {
        const { archetype, name } = intent.parameters;
        if (!archetype || !name) {
            return {
                success: false,
                message: 'Укажите тип и название проекта.',
                example: 'Создай проект telegram-bot my-bot'
            };
        }
        // Stream progress
        await this.streamProgress(session, {
            stage: 'validating',
            progress: 10,
            message: `Валидация архетипа ${archetype}...`
        });
        // Execute command
        const command = `make new ARCHETYPE=${archetype} NAME=${name}`;
        await this.streamProgress(session, {
            stage: 'executing',
            progress: 30,
            message: `Создаю проект ${name}...`
        });
        const result = await this.executeCommand(command, session.cwd || this.workspace);
        await this.streamProgress(session, {
            stage: 'complete',
            progress: 100,
            message: `[OK] Проект ${name} создан!`
        });
        return {
            success: true,
            message: `[OK] Проект "${name}" успешно создан!

Location: ${this.workspace}/${name}

Next steps:
1. cd ${name}
2. cp .env.example .env
3. make install
4. make dev
`,
            location: `${this.workspace}/${name}`
        };
    }
    /**
     * Execute: Generate Agents
     */
    async executeGenerateAgents(intent, session) {
        const { project_name, project_type } = intent.parameters;
        if (!project_name) {
            return {
                success: false,
                message: 'Укажите название проекта для генерации агентов.',
                example: 'Сгенерируй агентов для my-service'
            };
        }
        await this.streamProgress(session, {
            stage: 'analyzing',
            progress: 20,
            message: `Анализ проекта ${project_name}...`
        });
        const command = `make generate-agents NAME=${project_name}`;
        await this.streamProgress(session, {
            stage: 'executing',
            progress: 50,
            message: `Генерирую агентов для ${project_name}...`
        });
        const result = await this.executeCommand(command, session.cwd || this.workspace);
        await this.streamProgress(session, {
            stage: 'complete',
            progress: 100,
            message: `[OK] Агенты сгенерированы!`
        });
        return {
            success: true,
            message: `[OK] Агенты для проекта "${project_name}" сгенерированы!

Location: ${project_name}/.claude/

Созданные агенты:
• Coordinator
• Code Assistant
• Reviewer
• Documentation
• Tester
`
        };
    }
    /**
     * Execute: Deploy
     */
    async executeDeploy(intent, session) {
        const { environment, project_name } = intent.parameters;
        await this.streamProgress(session, {
            stage: 'preparing',
            progress: 10,
            message: `Подготовка деплоя на ${environment}...`
        });
        const command = `make deploy ENV=${environment}`;
        await this.streamProgress(session, {
            stage: 'executing',
            progress: 30,
            message: `Деплой на ${environment}...`
        });
        const result = await this.executeCommand(command, session.projectDir || process.cwd());
        await this.streamProgress(session, {
            stage: 'verifying',
            progress: 90,
            message: `Проверка деплоя...`
        });
        return {
            success: true,
            message: `[OK] Успешно задеплоено на ${environment}!`
        };
    }
    /**
     * Stream progress to WebSocket client
     */
    async streamProgress(session, update) {
        const ws = this.getWebSocket(session.id);
        if (!ws)
            return;
        this.sendMessage(ws, {
            type: 'progress',
            sessionId: session.id,
            ...update
        });
    }
    /**
     * Get WebSocket connection by session ID
     */
    getWebSocket(sessionId) {
        for (const client of this.wss.clients) {
            if (client.readyState === ws_1.WebSocket.OPEN) {
                const session = this.sessions.get(sessionId);
                if (session && client === session.ws) {
                    return client;
                }
            }
        }
        return null;
    }
    /**
     * Execute shell command and stream output
     */
    async executeCommand(command, cwd) {
        const { exec } = require('child_process');
        return new Promise((resolve, reject) => {
            exec(command, { cwd, timeout: 120000 }, (error, stdout, stderr) => {
                if (error) {
                    reject(error);
                }
                else {
                    resolve(stdout);
                }
            });
        });
    }
    /**
     * Get status text
     */
    getStatus(session) {
        return `[STATUS] Текущий статус:

Сессия: ${session.id}
Агент: ${session.currentAgent}
Задача: ${session.currentTask || 'нет активной задачи'}
Сообщений: ${session.messages.length}
Время: ${Math.floor((Date.now() - session.startedAt.getTime()) / 1000)} сек

Рабочая директория: ${session.projectDir || 'не установлена'}`;
    }
    /**
     * Get help text
     */
    getHelpText() {
        return `[HELP] Справка по OpenClaw Gateway:

## Основные команды

### Создание проектов
• "Создай проект telegram-bot my-bot"
• "Создай web-service api"
• "Создай fullstack my-saas"

### Агенты
• main — основной координатор
• dev — разработка
• devops — инфраструктура
• prompt — промпт инженерия
• codefoundry — генерация проектов

### Деплой
• "Задеплой на staging"
• "Задеплой на production"

### Другое
• "Покажи статус" — статус сессии
• "/help" — эта справка
• "/exit" — завершить сессию

## Примеры диалога

Вы: Создай проект
Gateway: Какой тип проекта?
Вы: telegram-bot
Gateway: Как назвать проект?
Вы: delivery-bot
Gateway: [создаёт проект...]

Вы: Задеплой на staging
Gateway: [деплоит...]

## Документация
• openclaw/README.md — полное руководство
• openclaw/docker/README.md — Docker stack
• openclaw/workspace/AGENTS.md — все агенты`;
    }
    /**
     * Extract username from request (if available)
     */
    getUsernameFromReq(req) {
        // Try to get username from various sources
        if (req.headers['x-telegram-username']) {
            return `telegram:${req.headers['x-telegram-username']}`;
        }
        if (req.headers['x-forwarded-for']) {
            const ips = req.headers['x-forwarded-for'].split(',')[0];
            return `browser:${ips}`;
        }
        return `socket:${req.socket.remoteAddress}`;
    }
    /**
     * Generate unique session ID
     */
    generateSessionId() {
        return `session_${(0, uuid_1.v4)()}`;
    }
    /**
     * Send message to WebSocket client
     */
    sendMessage(ws, message) {
        if (ws.readyState === 1) { // WebSocket.OPEN = 1
            ws.send(JSON.stringify(message));
        }
    }
    /**
     * Handle WebSocket error
     */
    handleError(error) {
        console.error('[ERROR] WebSocket:', error);
    }
    /**
     * Handle connection close
     */
    handleClose(sessionId) {
        const session = this.sessions.get(sessionId);
        if (session) {
            console.log(`Session closed: ${sessionId} (duration: ${Math.floor((Date.now() - session.startedAt.getTime()) / 1000)}s)`);
            this.sessions.delete(sessionId);
        }
    }
    /**
     * Get session statistics
     */
    getStats() {
        const now = Date.now();
        const sessions = Array.from(this.sessions.values());
        return {
            totalSessions: sessions.length,
            activeSessions: sessions.filter(s => (now - s.lastActivity.getTime()) < 3600000).length,
            avgDuration: sessions.length > 0
                ? sessions.reduce((sum, s) => sum + (now - s.startedAt.getTime()), 0) / sessions.length
                : 0
        };
    }
    /**
     * Shutdown gateway
     */
    shutdown() {
        console.log('[SHUTDOWN] OpenClaw Gateway stopping...');
        // Close all WebSocket connections
        this.wss.clients.forEach((client) => {
            client.close(1000, 'Server shutting down');
        });
        // Close WebSocket server
        this.wss.close(() => {
            this.httpServer.close();
        });
    }
}
exports.OpenClawGateway = OpenClawGateway;
// ============================================================================
// MAIN ENTRY POINT
// ============================================================================
if (require.main === module) {
    const gateway = new OpenClawGateway({
        port: GATEWAY_PORT,
        host: GATEWAY_HOST,
        workspace: process.env.WORKSPACE || '/workspace/system-prompts'
    });
    // Graceful shutdown
    process.on('SIGTERM', () => gateway.shutdown());
    process.on('SIGINT', () => gateway.shutdown());
}
//# sourceMappingURL=gateway.js.map