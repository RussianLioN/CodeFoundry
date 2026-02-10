"use strict";
/**
 * Command Generator - AI-Powered NLP to Command Protocol
 *
 * Converts natural language requests to Command Protocol v1.0 JSON format.
 * Uses Ollama Cloud API with gemini-3-flash-preview for intent parsing.
 *
 * @see docs/commands/PROTOCOL-v1.md
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.AmbiguityError = exports.CommandGenerationError = exports.CommandGenerator = void 0;
exports.createCommandGenerator = createCommandGenerator;
const uuid_1 = require("uuid");
// ============================================================================
// SYSTEM PROMPT
// ============================================================================
const DEFAULT_SYSTEM_PROMPT = `You are a Command Generator for OpenClaw Gateway. Your task is to parse user requests and generate Command Protocol v1.0 JSON commands.

Available commands:
1. create_project — Create a new project via Claude Code
   - Parameters: name (required), archetype (optional), framework (optional)
   - Example: "create project my-app" → {"command": "create_project", "params": {"name": "my-app"}}

2. status — Get system status
   - Parameters: none
   - Example: "what's the status" → {"command": "status", "params": {}}

3. help — Show help
   - Parameters: none
   - Example: "help" → {"command": "help", "params": {}}

Rules:
- Return ONLY valid JSON, no explanation text
- If request is ambiguous, return: {"status": "ambiguity", "question": "...", "options": [...]}
- If request is unclear, return: {"status": "error", "error": "..."}
- Extract parameters from natural language
- Validate required parameters for each command

Response format:
{
  "status": "success" | "ambiguity" | "error",
  "command": "command_name",
  "confidence": 0.0-1.0,
  "parameters": {...},
  "question": "...",
  "options": [...],
  "error": "..."
}`;
// ============================================================================
// COMMAND GENERATOR CLASS
// ============================================================================
class CommandGenerator {
    ollama;
    systemPrompt;
    temperature;
    constructor(config) {
        this.ollama = config.ollamaClient;
        this.systemPrompt = config.systemPrompt || DEFAULT_SYSTEM_PROMPT;
        this.temperature = config.temperature || 0.3; // Lower temperature for consistent parsing
    }
    /**
     * Generate command from natural language
     */
    async generateCommand(userInput, context) {
        const intent = await this.parseIntent(userInput);
        // Handle ambiguity
        if (intent.status === 'ambiguity') {
            throw new AmbiguityError(intent.question || 'Request unclear', intent.options);
        }
        // Handle error
        if (intent.status === 'error') {
            throw new CommandGenerationError(intent.error || 'Failed to parse request');
        }
        // Validate command
        if (!intent.command) {
            throw new CommandGenerationError('No command generated');
        }
        // Build Command Protocol request
        const commandRequest = {
            version: '1.0',
            id: (0, uuid_1.v4)(),
            timestamp: new Date().toISOString(),
            command: intent.command,
            params: intent.parameters,
            context: {
                user_id: context?.user_id,
                session_id: context?.session_id,
            },
        };
        return commandRequest;
    }
    /**
     * Parse user intent using AI
     */
    async parseIntent(userInput) {
        const messages = [
            { role: 'system', content: this.systemPrompt },
            { role: 'user', content: `Parse this request: "${userInput}"` },
        ];
        try {
            const response = await this.ollama.chat(messages, {
                temperature: this.temperature,
            });
            // Parse AI response
            const parsed = JSON.parse(response.trim());
            // Validate response structure
            if (!parsed.status) {
                throw new Error('Invalid AI response: missing status');
            }
            return parsed;
        }
        catch (error) {
            console.error('[COMMAND-GEN] AI parsing failed:', error);
            // Fallback to rule-based parsing
            return this.fallbackParse(userInput);
        }
    }
    /**
     * Fallback rule-based parsing (keyword matching)
     */
    fallbackParse(userInput) {
        const lowerInput = userInput.toLowerCase();
        // Detect create_project intent
        if (this.detectCreateProject(lowerInput)) {
            return this.parseCreateProject(userInput);
        }
        // Detect status intent
        if (this.detectStatus(lowerInput)) {
            return {
                status: 'success',
                command: 'status',
                confidence: 0.7,
                parameters: {},
            };
        }
        // Detect help intent
        if (this.detectHelp(lowerInput)) {
            return {
                status: 'success',
                command: 'help',
                confidence: 0.9,
                parameters: {},
            };
        }
        // Ambiguous request
        return {
            status: 'ambiguity',
            question: 'Что вы хотите сделать?',
            options: ['Создать проект', 'Показать статус', 'Справка'],
            confidence: 0,
            parameters: {},
        };
    }
    /**
     * Detect create_project intent
     */
    detectCreateProject(input) {
        const createKeywords = ['созда', 'create', 'новый', 'new', 'сделай', 'сгенерируй'];
        const projectKeywords = ['проект', 'project', 'приложение', 'app', 'бот', 'bot'];
        return createKeywords.some(kw => input.includes(kw)) &&
            projectKeywords.some(kw => input.includes(kw));
    }
    /**
     * Parse create_project parameters
     */
    parseCreateProject(input) {
        const params = {};
        // Extract name (basic pattern matching)
        const namePatterns = [
            /(?:проект|project|app|бот|bot)\s+["']?([a-z0-9-]+)["']?/i,
            /(?:созда|create)\s+(?:.*?)\s+(?:назван|named|name)?\s+["']?([a-z0-9-]+)["']?/i,
        ];
        for (const pattern of namePatterns) {
            const match = input.match(pattern);
            if (match && match[1]) {
                params.name = match[1];
                break;
            }
        }
        // Extract archetype
        const archetypes = ['web-service', 'telegram-bot', 'ai-agent', 'fullstack', 'cli-tool'];
        const lowerInput = input.toLowerCase();
        for (const archetype of archetypes) {
            if (lowerInput.includes(archetype)) {
                params.archetype = archetype;
                break;
            }
        }
        // Validate required parameters
        if (!params.name) {
            return {
                status: 'ambiguity',
                question: 'Как назвать проект?',
                options: ['my-app', 'my-service', 'my-bot'],
                confidence: 0.5,
                parameters: params,
            };
        }
        return {
            status: 'success',
            command: 'create_project',
            confidence: 0.8,
            parameters: params,
        };
    }
    /**
     * Detect status intent
     */
    detectStatus(input) {
        const statusKeywords = ['статус', 'status', 'состояние', 'state', 'как дела', 'что происходит'];
        return statusKeywords.some(kw => input.includes(kw));
    }
    /**
     * Detect help intent
     */
    detectHelp(input) {
        const helpKeywords = ['помощь', 'help', 'справка', 'команд', 'что ты умеешь', 'как использовать'];
        return helpKeywords.some(kw => input.includes(kw));
    }
    /**
     * Get available commands
     */
    getAvailableCommands() {
        return ['create_project', 'status', 'help'];
    }
    /**
     * Get command examples
     */
    getCommandExamples() {
        return {
            create_project: [
                'Создай проект my-app',
                'Create project telegram-bot delivery-bot',
                'Создай web-service api',
            ],
            status: [
                'Покажи статус',
                'What\'s the status',
                'Статус системы',
            ],
            help: [
                'Помощь',
                'Help',
                'Что ты умеешь?',
            ],
        };
    }
}
exports.CommandGenerator = CommandGenerator;
// ============================================================================
// ERROR CLASSES
// ============================================================================
class CommandGenerationError extends Error {
    constructor(message) {
        super(`CommandGenerationError: ${message}`);
        this.name = 'CommandGenerationError';
    }
}
exports.CommandGenerationError = CommandGenerationError;
class AmbiguityError extends Error {
    options;
    constructor(message, options = []) {
        super(message);
        this.name = 'AmbiguityError';
        this.options = options;
    }
}
exports.AmbiguityError = AmbiguityError;
// ============================================================================
// FACTORY FUNCTION
// ============================================================================
/**
 * Create Command Generator with default Ollama client
 */
function createCommandGenerator(config) {
    const { createOllamaClient } = require('./ollama-client');
    return new CommandGenerator({
        ollamaClient: config?.ollamaClient || createOllamaClient(),
        systemPrompt: config?.systemPrompt,
        temperature: config?.temperature,
    });
}
//# sourceMappingURL=command-generator.js.map