/**
 * Command Generator - AI-Powered NLP to Command Protocol
 *
 * Converts natural language requests to Command Protocol v1.1 JSON format.
 * v2.0.1 UPDATE: Now integrates with Intent Classifier for better accuracy.
 *
 * Workflow:
 * 1. Intent Classifier classifies user message → intent + confidence
 * 2. Command Generator extracts parameters and generates Command Protocol
 * 3. CLI Bridge executes command via Claude Code
 *
 * @see docs/commands/PROTOCOL-v1.md
 * @see docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md
 */

import { v4 as uuidv4 } from 'uuid';
import { OllamaClient, OllamaMessage } from './ollama-client';

// ============================================================================
// TYPES
// ============================================================================

export interface CommandRequest {
  version: string;
  id: string;
  timestamp: string;
  intent_confidence?: number; // v2.0.1: AI intent classification confidence
  command: string;
  params: Record<string, any>;
  context: {
    user_id?: string;
    session_id?: string;
    request_id?: string;
  };
}

export interface ParsedIntent {
  status: 'success' | 'ambiguity' | 'error';
  category?: string;
  confidence: number;
  parameters: Record<string, any>;
  command?: string;
  question?: string;
  options?: string[];
  error?: string;
}

export interface CommandGeneratorConfig {
  ollamaClient: OllamaClient;
  systemPrompt?: string;
  temperature?: number;
}

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

export class CommandGenerator {
  private ollama: OllamaClient;
  private systemPrompt: string;
  private temperature: number;

  constructor(config: CommandGeneratorConfig) {
    this.ollama = config.ollamaClient;
    this.systemPrompt = config.systemPrompt || DEFAULT_SYSTEM_PROMPT;
    this.temperature = config.temperature || 0.3; // Lower temperature for consistent parsing
  }

  /**
   * Generate command from natural language
   * v2.0.1 UPDATE: Now accepts pre-classified intent from Intent Classifier
   */
  async generateCommand(
    userInput: string,
    context?: { user_id?: string; session_id?: string; intent_confidence?: number }
  ): Promise<CommandRequest> {
    // v2.0.1: If intent_confidence is provided, Intent Classifier already did classification
    // Otherwise, fall back to internal parsing (for backward compatibility)
    const intent = context?.intent_confidence
      ? await this.generateFromPreClassified(userInput, context.intent_confidence)
      : await this.parseIntent(userInput);

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
    const commandRequest: CommandRequest = {
      version: '1.1',
      id: uuidv4(),
      timestamp: new Date().toISOString(),
      intent_confidence: context?.intent_confidence || intent.confidence,
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
   * Generate command from pre-classified intent (v2.0.1 - NEW)
   * Used when Intent Classifier has already determined the intent
   */
  private async generateFromPreClassified(
    userInput: string,
    confidence: number
  ): Promise<ParsedIntent> {
    // Skip full AI parsing if confidence is high enough
    // Just extract parameters and validate
    const messages: OllamaMessage[] = [
      { role: 'system', content: this.systemPrompt },
      { role: 'user', content: `Extract parameters from: "${userInput}"` },
    ];

    try {
      const response = await this.ollama.chat(messages, {
        temperature: this.temperature,
      });

      const parsed = JSON.parse(response.trim()) as ParsedIntent;

      // Update confidence with Intent Classifier's value
      parsed.confidence = confidence;

      return parsed;
    } catch (error) {
      console.error('[COMMAND-GEN] Pre-classified parsing failed:', error);

      // Fallback to rule-based parsing
      return this.fallbackParse(userInput);
    }
  }

  /**
   * Parse user intent using AI
   */
  private async parseIntent(userInput: string): Promise<ParsedIntent> {
    const messages: OllamaMessage[] = [
      { role: 'system', content: this.systemPrompt },
      { role: 'user', content: `Parse this request: "${userInput}"` },
    ];

    try {
      const response = await this.ollama.chat(messages, {
        temperature: this.temperature,
      });

      // Parse AI response
      const parsed = JSON.parse(response.trim()) as ParsedIntent;

      // Validate response structure
      if (!parsed.status) {
        throw new Error('Invalid AI response: missing status');
      }

      return parsed;
    } catch (error) {
      console.error('[COMMAND-GEN] AI parsing failed:', error);

      // Fallback to rule-based parsing
      return this.fallbackParse(userInput);
    }
  }

  /**
   * Fallback rule-based parsing (keyword matching)
   */
  private fallbackParse(userInput: string): ParsedIntent {
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
  private detectCreateProject(input: string): boolean {
    const createKeywords = ['созда', 'create', 'новый', 'new', 'сделай', 'сгенерируй'];
    const projectKeywords = ['проект', 'project', 'приложение', 'app', 'бот', 'bot'];

    return createKeywords.some(kw => input.includes(kw)) &&
           projectKeywords.some(kw => input.includes(kw));
  }

  /**
   * Parse create_project parameters
   */
  private parseCreateProject(input: string): ParsedIntent {
    const params: Record<string, any> = {};

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
  private detectStatus(input: string): boolean {
    const statusKeywords = ['статус', 'status', 'состояние', 'state', 'как дела', 'что происходит'];
    return statusKeywords.some(kw => input.includes(kw));
  }

  /**
   * Detect help intent
   */
  private detectHelp(input: string): boolean {
    const helpKeywords = ['помощь', 'help', 'справка', 'команд', 'что ты умеешь', 'как использовать'];
    return helpKeywords.some(kw => input.includes(kw));
  }

  /**
   * Get available commands
   */
  getAvailableCommands(): string[] {
    return ['create_project', 'status', 'help'];
  }

  /**
   * Get command examples
   */
  getCommandExamples(): Record<string, string[]> {
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

// ============================================================================
// ERROR CLASSES
// ============================================================================

export class CommandGenerationError extends Error {
  constructor(message: string) {
    super(`CommandGenerationError: ${message}`);
    this.name = 'CommandGenerationError';
  }
}

export class AmbiguityError extends Error {
  public readonly options: string[];

  constructor(message: string, options: string[] = []) {
    super(message);
    this.name = 'AmbiguityError';
    this.options = options;
  }
}

// ============================================================================
// FACTORY FUNCTION
// ============================================================================

/**
 * Create Command Generator with default Ollama client
 */
export function createCommandGenerator(config?: Partial<CommandGeneratorConfig>): CommandGenerator {
  const { createOllamaClient } = require('./ollama-client');

  return new CommandGenerator({
    ollamaClient: config?.ollamaClient || createOllamaClient(),
    systemPrompt: config?.systemPrompt,
    temperature: config?.temperature,
  });
}
