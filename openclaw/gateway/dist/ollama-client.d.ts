/**
 * Ollama Cloud API Client
 *
 * Client for Ollama Cloud Inference API.
 * Supports gemini-3-flash-preview:cloud model with 1M+ token context.
 *
 * @see https://ollama.com/blog/cloud-api
 * @see https://ollama.com/library/gemini-3-flash-preview
 */
export interface OllamaMessage {
    role: 'system' | 'user' | 'assistant';
    content: string;
}
export interface OllamaChatRequest {
    model: string;
    messages: OllamaMessage[];
    stream?: boolean;
    format?: 'json' | 'text';
    options?: {
        temperature?: number;
        top_p?: number;
        top_k?: number;
        num_predict?: number;
    };
}
export interface OllamaChatResponse {
    model: string;
    created_at: string;
    message: OllamaMessage;
    done: boolean;
    context?: number[];
    prompt_eval_count?: number;
    eval_count?: number;
}
export interface OllamaStreamChunk {
    model: string;
    created_at: string;
    message: OllamaMessage;
    done: boolean;
}
export interface OllamaError {
    error: string;
    status?: number;
}
export interface OllamaConfig {
    baseURL?: string;
    apiKey?: string;
    model?: string;
    timeout?: number;
}
export declare class OllamaClient {
    private client;
    private model;
    private apiKey?;
    constructor(config?: OllamaConfig);
    /**
     * Send chat completion request (non-streaming)
     */
    chat(messages: OllamaMessage[], options?: OllamaChatRequest['options']): Promise<string>;
    /**
     * Send chat completion request (streaming)
     */
    chatStream(messages: OllamaMessage[], options?: OllamaChatRequest['options']): AsyncGenerator<string, void, unknown>;
    /**
     * Test connection to Ollama API
     */
    testConnection(): Promise<boolean>;
    /**
     * Get model information
     */
    getModel(): string;
    /**
     * Create a new instance with different model
     */
    withModel(model: string): OllamaClient;
}
/**
 * Create Ollama client from environment variables
 */
export declare function createOllamaClient(): OllamaClient;
/**
 * Create Ollama client for local Ollama instance
 */
export declare function createLocalOllamaClient(baseURL?: string): OllamaClient;
//# sourceMappingURL=ollama-client.d.ts.map