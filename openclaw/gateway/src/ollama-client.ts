/**
 * Ollama Cloud API Client
 *
 * Client for Ollama Cloud Inference API.
 * Supports gemini-3-flash-preview:cloud model with 1M+ token context.
 *
 * @see https://ollama.com/blog/cloud-api
 * @see https://ollama.com/library/gemini-3-flash-preview
 */

import axios, { AxiosInstance } from 'axios';

// ============================================================================
// TYPES
// ============================================================================

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

// ============================================================================
// CONFIGURATION
// ============================================================================

export interface OllamaConfig {
  baseURL?: string;
  apiKey?: string;
  model?: string;
  timeout?: number;
}

const DEFAULT_CONFIG: Omit<OllamaConfig, 'apiKey'> = {
  baseURL: 'https://ollama.com',
  model: 'gemini-3-flash-preview:cloud',
  timeout: 120000, // 2 minutes
};

// ============================================================================
// OLLAMA CLIENT CLASS
// ============================================================================

export class OllamaClient {
  private client: AxiosInstance;
  private model: string;
  private apiKey?: string;

  constructor(config: OllamaConfig = {}) {
    const { baseURL, apiKey, model, timeout } = { ...DEFAULT_CONFIG, ...config };

    // Validate configuration
    if (!baseURL) {
      throw new Error('OllamaClient: baseURL is required');
    }

    this.model = model || DEFAULT_CONFIG.model!;
    this.apiKey = apiKey;

    // Create axios instance
    this.client = axios.create({
      baseURL,
      timeout: timeout || DEFAULT_CONFIG.timeout,
      headers: {
        'Content-Type': 'application/json',
        ...(apiKey && { 'Authorization': `Bearer ${apiKey}` }),
      },
    });

    // Add request interceptor for logging
    this.client.interceptors.request.use(
      (config) => {
        if (process.env.NODE_ENV === 'development') {
          console.log(`[OLLAMA] ${config.method?.toUpperCase()} ${config.url}`);
        }
        return config;
      },
      (error) => {
        console.error('[OLLAMA] Request error:', error.message);
        return Promise.reject(error);
      }
    );

    // Add response interceptor for error handling
    this.client.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response) {
          // Server responded with error status
          const status = error.response.status;
          const message = error.response.data?.error || error.message;

          if (status === 401) {
            throw new Error('Ollama API: Unauthorized - check API key');
          } else if (status === 429) {
            throw new Error('Ollama API: Rate limit exceeded');
          } else if (status >= 500) {
            throw new Error(`Ollama API: Server error (${status}) - ${message}`);
          } else {
            throw new Error(`Ollama API: ${message}`);
          }
        } else if (error.request) {
          // Request made but no response
          throw new Error('Ollama API: No response - check network connection');
        } else {
          // Error setting up request
          throw new Error(`Ollama API: ${error.message}`);
        }
      }
    );
  }

  /**
   * Send chat completion request (non-streaming)
   */
  async chat(messages: OllamaMessage[], options?: OllamaChatRequest['options']): Promise<string> {
    const request: OllamaChatRequest = {
      model: this.model,
      messages,
      stream: false,
      ...(options && { options }),
    };

    try {
      const response = await this.client.post('/v1/chat/completions', request);
      const data: OllamaChatResponse = response.data;

      // Ollama Cloud API returns OpenAI-compatible format
      // Extract content from response
      if (data.message && data.message.content) {
        return data.message.content;
      }

      // Alternative format (OpenAI-compatible)
      if (response.data.choices && response.data.choices[0]) {
        return response.data.choices[0].message.content;
      }

      throw new Error('Unexpected response format from Ollama API');
    } catch (error) {
      console.error('[OLLAMA] Chat error:', error);
      throw error;
    }
  }

  /**
   * Send chat completion request (streaming)
   */
  async *chatStream(
    messages: OllamaMessage[],
    options?: OllamaChatRequest['options']
  ): AsyncGenerator<string, void, unknown> {
    const request: OllamaChatRequest = {
      model: this.model,
      messages,
      stream: true,
      ...(options && { options }),
    };

    try {
      const response = await this.client.post('/v1/chat/completions', request, {
        responseType: 'stream',
      });

      // Stream chunks
      for await (const chunk of response.data) {
        const lines = chunk.toString().split('\n').filter((line: string) => line.trim());

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = line.slice(6);

            if (data === '[DONE]') {
              return;
            }

            try {
              const parsed: OllamaStreamChunk = JSON.parse(data);

              if (parsed.message && parsed.message.content) {
                yield parsed.message.content;
              }

              if (parsed.done) {
                return;
              }
            } catch (parseError) {
              console.warn('[OLLAMA] Failed to parse stream chunk:', parseError);
            }
          }
        }
      }
    } catch (error) {
      console.error('[OLLAMA] Stream error:', error);
      throw error;
    }
  }

  /**
   * Test connection to Ollama API
   */
  async testConnection(): Promise<boolean> {
    try {
      const response = await this.client.get('/v1/models');
      return response.status === 200;
    } catch (error) {
      console.error('[OLLAMA] Connection test failed:', error);
      return false;
    }
  }

  /**
   * Get model information
   */
  getModel(): string {
    return this.model;
  }

  /**
   * Create a new instance with different model
   */
  withModel(model: string): OllamaClient {
    return new OllamaClient({
      baseURL: this.client.defaults.baseURL,
      apiKey: this.apiKey,
      model,
      timeout: this.client.defaults.timeout as number,
    });
  }
}

// ============================================================================
// FACTORY FUNCTIONS
// ============================================================================

/**
 * Create Ollama client from environment variables
 */
export function createOllamaClient(): OllamaClient {
  const baseURL = process.env.OLLAMA_BASE_URL || 'https://ollama.com';
  const apiKey = process.env.OLLAMA_API_KEY;
  const model = process.env.OLLAMA_MODEL || 'gemini-3-flash-preview:cloud';
  const timeout = parseInt(process.env.OLLAMA_TIMEOUT || '120000');

  return new OllamaClient({ baseURL, apiKey, model, timeout });
}

/**
 * Create Ollama client for local Ollama instance
 */
export function createLocalOllamaClient(baseURL: string = 'http://localhost:11434'): OllamaClient {
  return new OllamaClient({ baseURL, model: 'gemini-3-flash-preview' });
}
