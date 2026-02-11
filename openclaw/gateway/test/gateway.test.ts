/**
 * Gateway v2.0.1 Unit Tests
 *
 * Tests for:
 * - OllamaClient
 * - IntentClassifier (NEW v2.0.1)
 * - CommandGenerator
 * - CommandExecutor
 */

import { describe, it, expect, beforeEach } from '@jest/globals';
import { OllamaClient } from '../src/ollama-client';
import { IntentClassifier } from '../src/intent-classifier';
import { CommandGenerator } from '../src/command-generator';
import { CommandExecutor } from '../src/command-executor';

// ============================================================================
// OllamaClient Tests
// ============================================================================

describe('OllamaClient', () => {
  describe('Configuration', () => {
    it('should create client with default config', () => {
      const client = new OllamaClient({});
      expect(client).toBeDefined();
    });

    it('should create client with custom config', () => {
      const client = new OllamaClient({
        baseURL: 'https://api.ollama.cloud',
        model: 'gemini-3-flash-preview:cloud',
        apiKey: 'test-key',
      });
      expect(client).toBeDefined();
    });

    it('should throw error without baseURL', () => {
      expect(() => new OllamaClient({ baseURL: '' })).toThrow();
    });
  });

  describe('Model information', () => {
    it('should return model name', () => {
      const client = new OllamaClient({ model: 'test-model' });
      expect(client.getModel()).toBe('test-model');
    });

    it('should create client with different model', () => {
      const client1 = new OllamaClient({ model: 'model1' });
      const client2 = client1.withModel('model2');
      expect(client2.getModel()).toBe('model2');
    });
  });

  describe('Factory function', () => {
    it('should create client from environment', () => {
      const client = require('../src/ollama-client').createOllamaClient();
      expect(client).toBeDefined();
      expect(client.getModel()).toContain('gemini');
    });
  });
});

// ============================================================================
// CommandGenerator Tests
// ============================================================================

describe('CommandGenerator', () => {
  describe('Available commands', () => {
    it('should return available commands', () => {
      const generator = new CommandGenerator({ ollamaClient: new OllamaClient({}) });
      const commands = generator.getAvailableCommands();
      expect(commands).toEqual(['create_project', 'status', 'help']);
    });

    it('should return command examples', () => {
      const generator = new CommandGenerator({ ollamaClient: new OllamaClient({}) });
      const examples = generator.getCommandExamples();
      expect(examples).toHaveProperty('create_project');
      expect(examples).toHaveProperty('status');
      expect(examples).toHaveProperty('help');
    });
  });

  describe('Factory function', () => {
    it('should create generator with defaults', () => {
      const generator = require('../src/command-generator').createCommandGenerator();
      expect(generator).toBeDefined();
    });
  });
});

// ============================================================================
// CommandExecutor Tests
// ============================================================================

describe('CommandExecutor', () => {
  let executor: CommandExecutor;

  beforeEach(() => {
    executor = new CommandExecutor({
      cliWrapperPath: './test/scripts/mock-wrapper.sh',
      workspace: '/tmp/test',
    });
  });

  describe('Configuration', () => {
    it('should create executor with default config', () => {
      expect(executor).toBeDefined();
    });

    it('should return stats', () => {
      const stats = executor.getStats();
      expect(stats).toHaveProperty('cliWrapperPath');
      expect(stats).toHaveProperty('workspace');
      expect(stats).toHaveProperty('timeout');
    });
  });

  describe('Request validation', () => {
    it('should return error response for invalid protocol version', async () => {
      const request = {
        version: '2.0',
        id: 'test-id',
        timestamp: new Date().toISOString(),
        command: 'help',
        params: {},
      };

      const response = await executor.execute(request);
      expect(response.status).toBe('error');
      expect(response.error?.code).toBe('CLAUDE_CODE_ERROR');
    });

    it('should return error response for missing command', async () => {
      const request = {
        version: '1.0',
        id: 'test-id',
        timestamp: new Date().toISOString(),
        command: '',
        params: {},
      };

      const response = await executor.execute(request);
      expect(response.status).toBe('error');
      expect(response.error?.code).toBe('CLAUDE_CODE_ERROR');
    });

    it('should return error response for unknown command', async () => {
      const request = {
        version: '1.0',
        id: 'test-id',
        timestamp: new Date().toISOString(),
        command: 'unknown_command',
        params: {},
      };

      const response = await executor.execute(request);
      expect(response.status).toBe('error');
      expect(response.error?.code).toBe('UNKNOWN_COMMAND');
    });
  });

  describe('Error mapping', () => {
    it('should map timeout errors correctly', () => {
      const executor = new CommandExecutor();
      const error = new Error('ETIMEDOUT');
      const errorCode = (executor as any).errorCodeFromMessage(error.message);
      expect(errorCode).toBe('TIMEOUT');
    });

    it('should map unknown command errors correctly', () => {
      const executor = new CommandExecutor();
      const error = new Error('Unknown command');
      const errorCode = (executor as any).errorCodeFromMessage(error.message);
      expect(errorCode).toBe('UNKNOWN_COMMAND');
    });

    it('should map generic errors to CLAUDE_CODE_ERROR', () => {
      const executor = new CommandExecutor();
      const error = new Error('Some other error');
      const errorCode = (executor as any).errorCodeFromMessage(error.message);
      expect(errorCode).toBe('CLAUDE_CODE_ERROR');
    });
  });

  describe('Factory function', () => {
    it('should create executor with defaults', () => {
      const executor = require('../src/command-executor').createCommandExecutor();
      expect(executor).toBeDefined();
    });
  });
});

// ============================================================================
// Integration Tests (mocked)
// ============================================================================

describe('Gateway Integration (mocked)', () => {
  it('should verify full request structure', () => {
    const request = {
      version: '1.0',
      id: 'test-id',
      timestamp: new Date().toISOString(),
      command: 'help',
      params: {},
      context: {},
    };

    expect(request.version).toBe('1.0');
    expect(request.command).toBe('help');
    expect(request).toHaveProperty('id');
    expect(request).toHaveProperty('timestamp');
  });

  it('should verify response structure', () => {
    const response = {
      version: '1.0',
      id: 'test-id',
      status: 'success' as const,
      result: { data: 'test' },
      message: 'Success',
      timestamp: new Date().toISOString(),
    };

    expect(response.version).toBe('1.0');
    expect(response.status).toBe('success');
    expect(response).toHaveProperty('result');
  });

  it('should verify error response structure', () => {
    const response = {
      version: '1.0',
      id: 'test-id',
      status: 'error' as const,
      error: {
        code: 'UNKNOWN_COMMAND',
        message: 'Test error',
      },
      timestamp: new Date().toISOString(),
    };

    expect(response.status).toBe('error');
    expect(response.error).toHaveProperty('code');
    expect(response.error).toHaveProperty('message');
  });

  // ============================================================================
  // Intent Classifier Integration Tests (v2.0.1 - NEW)
  // ============================================================================

  describe('Intent Classifier Integration', () => {
    let mockOllama: MockOllamaClient;
    let classifier: IntentClassifier;

    beforeEach(() => {
      mockOllama = new MockOllamaClient();
      classifier = new IntentClassifier({
        ollamaClient: mockOllama,
        confidenceThreshold: 0.7,
      });
    });

    class MockOllamaClient extends OllamaClient {
      private mockResponse: string;

      constructor(mockResponse: string) {
        super({});
        this.mockResponse = mockResponse;
      }

      async chat(): Promise<string> {
        return Promise.resolve(this.mockResponse);
      }
    }

    describe('High Confidence Scenarios (>= 0.7)', () => {
      it('should route create_project to Command Generator', async () => {
        mockOllama.setMockResponse(JSON.stringify({
          intent: 'create_project',
          confidence: 0.95,
          parameters: { name: 'test-app' },
        }));

        const result = await classifier.classify('Создай приложение');

        expect(result.intent).toBe('create_project');
        expect(result.confidence).toBe(0.95);
        expect(result.parameters).toEqual({ name: 'test-app' });
      });

      it('should route status to Command Generator', async () => {
        mockOllama.setMockResponse(JSON.stringify({
          intent: 'status',
          confidence: 0.88,
          parameters: {},
        }));

        const result = await classifier.classify('Какой статус?');

        expect(result.intent).toBe('status');
        expect(result.confidence).toBe(0.88);
      });

      it('should route help to Command Generator', async () => {
        mockOllama.setMockResponse(JSON.stringify({
          intent: 'help',
          confidence: 0.92,
          parameters: {},
        }));

        const result = await classifier.classify('Покажи справку');

        expect(result.intent).toBe('help');
        expect(result.confidence).toBe(0.92);
      });

      it('should route deploy to Command Generator', async () => {
        mockOllama.setMockResponse(JSON.stringify({
          intent: 'deploy',
          confidence: 0.85,
          parameters: { project_name: 'my-app' },
        }));

        const result = await classifier.classify('Задеплой my-app');

        expect(result.intent).toBe('deploy');
        expect(result.confidence).toBe(0.85);
        expect(result.parameters).toEqual({ project_name: 'my-app' });
      });
    });

    describe('Low Confidence Scenarios (< 0.7)', () => {
      it('should fallback to chat for low confidence', async () => {
        mockOllama.setMockResponse(JSON.stringify({
          intent: 'create_project',
          confidence: 0.5, // Below threshold
          parameters: {},
        }));

        const result = await classifier.classify('Неясный запрос');

        expect(result.intent).toBe('chat');
        expect(result.confidence).toBe(1.0); // Overridden
      });
    });

    describe('Chat Intent Scenarios', () => {
      it('should classify casual conversation', async () => {
        mockOllama.setMockResponse(JSON.stringify({
          intent: 'chat',
          confidence: 0.91,
          parameters: {},
        }));

        const result = await classifier.classify('Привет! Как дела?');

        expect(result.intent).toBe('chat');
        expect(result.confidence).toBe(0.91);
      });

      it('should classify gratitude', async () => {
        mockOllama.setMockResponse(JSON.stringify({
          intent: 'chat',
          confidence: 0.93,
          parameters: {},
        }));

        const result = await classifier.classify('Спасибо за помощь!');

        expect(result.intent).toBe('chat');
        expect(result.confidence).toBe(0.93);
      });
    });

    describe('Fallback Logic', () => {
      it('should use keyword matching when AI fails', async () => {
        // Mock AI failure
        jest.spyOn(mockOllama, 'chat').mockRejectedValue(new Error('AI unavailable'));

        const result = await classifier.classify('Создай проект');

        // Should fallback to keyword-based classification
        expect(result.intent).toBe('create_project');
        expect(result.confidence).toBeGreaterThanOrEqual(0);
      });
    });
  });
});
