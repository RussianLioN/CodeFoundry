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
import { OllamaClient } from './ollama-client';
export interface CommandRequest {
    version: string;
    id: string;
    timestamp: string;
    intent_confidence?: number;
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
export declare class CommandGenerator {
    private ollama;
    private systemPrompt;
    private temperature;
    constructor(config: CommandGeneratorConfig);
    /**
     * Generate command from natural language
     * v2.0.1 UPDATE: Now accepts pre-classified intent from Intent Classifier
     */
    generateCommand(userInput: string, context?: {
        user_id?: string;
        session_id?: string;
        intent_confidence?: number;
    }): Promise<CommandRequest>;
    /**
     * Generate command from pre-classified intent (v2.0.1 - NEW)
     * Used when Intent Classifier has already determined the intent
     */
    private generateFromPreClassified;
    /**
     * Parse user intent using AI
     */
    private parseIntent;
    /**
     * Fallback rule-based parsing (keyword matching)
     */
    private fallbackParse;
    /**
     * Detect create_project intent
     */
    private detectCreateProject;
    /**
     * Parse create_project parameters
     */
    private parseCreateProject;
    /**
     * Detect status intent
     */
    private detectStatus;
    /**
     * Detect help intent
     */
    private detectHelp;
    /**
     * Get available commands
     */
    getAvailableCommands(): string[];
    /**
     * Get command examples
     */
    getCommandExamples(): Record<string, string[]>;
}
export declare class CommandGenerationError extends Error {
    constructor(message: string);
}
export declare class AmbiguityError extends Error {
    readonly options: string[];
    constructor(message: string, options?: string[]);
}
/**
 * Create Command Generator with default Ollama client
 */
export declare function createCommandGenerator(config?: Partial<CommandGeneratorConfig>): CommandGenerator;
//# sourceMappingURL=command-generator.d.ts.map