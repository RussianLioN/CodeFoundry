/**
 * Intent Classifier v2.0.1 Unit Tests
 *
 * Tests for AI-powered intent classification component.
 * @see openclaw/gateway/src/intent-classifier.ts
 */

import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { IntentClassifier, createIntentClassifier, IntentType, IntentResult } from '../src/intent-classifier';
import { OllamaClient } from '../src/ollama-client';

// ============================================================================
// Mocks
// ============================================================================

class MockOllamaClient extends OllamaClient {
  private mockResponse: string;
  private mockShouldFail: boolean = false;

  constructor(mockResponse: string = '{"intent": "chat", "confidence": 0.8, "parameters": {}}') {
    super({});
    this.mockResponse = mockResponse;
  }

  setMockResponse(response: string): void {
    this.mockResponse = response;
  }

  setShouldFail(shouldFail: boolean): void {
    this.mockShouldFail = shouldFail;
  }

  async chat(): Promise<string> {
    if (this.mockShouldFail) {
      throw new Error('AI classification failed');
    }
    return Promise.resolve(this.mockResponse);
  }
}

// ============================================================================
// Test Suite
// ============================================================================

describe('IntentClassifier', () => {
  let classifier: IntentClassifier;
  let mockOllama: MockOllamaClient;

  beforeEach(() => {
    mockOllama = new MockOllamaClient();
    classifier = new IntentClassifier({
      ollamaClient: mockOllama,
      confidenceThreshold: 0.7,
    });
  });

  // ============================================================================
  // Configuration Tests
  // ============================================================================

  describe('Configuration', () => {
    it('should create with default config', () => {
      expect(classifier).toBeDefined();
      expect(classifier.getConfidenceThreshold()).toBe(0.7);
    });

    it('should create with custom confidence threshold', () => {
      const customClassifier = new IntentClassifier({
        ollamaClient: mockOllama,
        confidenceThreshold: 0.5,
      });
      expect(customClassifier.getConfidenceThreshold()).toBe(0.5);
    });

    it('should set confidence threshold', () => {
      classifier.setConfidenceThreshold(0.8);
      expect(classifier.getConfidenceThreshold()).toBe(0.8);
    });

    it('should throw error for invalid threshold (< 0)', () => {
      expect(() => classifier.setConfidenceThreshold(-0.1)).toThrow();
    });

    it('should throw error for invalid threshold (> 1)', () => {
      expect(() => classifier.setConfidenceThreshold(1.5)).toThrow();
    });
  });

  // ============================================================================
  // Intent Classification Tests
  // ============================================================================

  describe('AI Classification', () => {
    it('should classify create_project intent with high confidence', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'create_project',
        confidence: 0.95,
        parameters: { name: 'my-app', archetype: 'web-service' },
      }));

      const result = await classifier.classify('Создай проект my-app');

      expect(result.intent).toBe('create_project');
      expect(result.confidence).toBe(0.95);
      expect(result.parameters).toEqual({ name: 'my-app', archetype: 'web-service' });
    });

    it('should classify status intent with high confidence', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'status',
        confidence: 0.92,
        parameters: {},
      }));

      const result = await classifier.classify('Какой статус?');

      expect(result.intent).toBe('status');
      expect(result.confidence).toBe(0.92);
      expect(result.parameters).toEqual({});
    });

    it('should classify help intent with high confidence', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'help',
        confidence: 0.98,
        parameters: {},
      }));

      const result = await classifier.classify('Помощь');

      expect(result.intent).toBe('help');
      expect(result.confidence).toBe(0.98);
    });

    it('should classify deploy intent with high confidence', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'deploy',
        confidence: 0.88,
        parameters: { project_name: 'my-app' },
      }));

      const result = await classifier.classify('Задеплой my-app');

      expect(result.intent).toBe('deploy');
      expect(result.confidence).toBe(0.88);
      expect(result.parameters).toEqual({ project_name: 'my-app' });
    });

    it('should classify chat intent with high confidence', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'chat',
        confidence: 0.91,
        parameters: {},
      }));

      const result = await classifier.classify('Привет, как дела?');

      expect(result.intent).toBe('chat');
      expect(result.confidence).toBe(0.91);
    });
  });

  // ============================================================================
  // Confidence Threshold Tests
  // ============================================================================

  describe('Confidence Threshold', () => {
    it('should return chat intent for low confidence (< 0.7)', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'create_project',
        confidence: 0.5, // Below threshold
        parameters: {},
      }));

      const result = await classifier.classify('Неясный запрос');

      expect(result.intent).toBe('chat'); // Fallback to chat
      expect(result.confidence).toBe(1.0); // Overridden to 1.0
    });

    it('should return original intent for high confidence (>= 0.7)', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'status',
        confidence: 0.75, // Above threshold
        parameters: {},
      }));

      const result = await classifier.classify('Какой статус?');

      expect(result.intent).toBe('status');
      expect(result.confidence).toBe(0.75);
    });

    it('should work with custom threshold', async () => {
      const customClassifier = new IntentClassifier({
        ollamaClient: mockOllama,
        confidenceThreshold: 0.5,
      });

      mockOllama.setMockResponse(JSON.stringify({
        intent: 'help',
        confidence: 0.6, // Above 0.5 threshold
        parameters: {},
      }));

      const result = await customClassifier.classify('Помощь');

      expect(result.intent).toBe('help');
      expect(result.confidence).toBe(0.6);
    });
  });

  // ============================================================================
  // Fallback Logic Tests
  // ============================================================================

  describe('Fallback Logic', () => {
    it('should use fallback when AI fails', async () => {
      mockOllama.setShouldFail(true);

      const result = await classifier.classify('Создай проект my-app');

      expect(result.intent).toBe('create_project');
      expect(result.confidence).toBe(0.6); // Fallback confidence
      expect(result.parameters).toEqual({ name: 'my-app' });
    });

    it('should fallback to status detection', async () => {
      mockOllama.setShouldFail(true);

      const result = await classifier.classify('Какой статус системы?');

      expect(result.intent).toBe('status');
      expect(result.confidence).toBe(0.7);
    });

    it('should fallback to help detection', async () => {
      mockOllama.setShouldFail(true);

      const result = await classifier.classify('Что ты умеешь?');

      expect(result.intent).toBe('help');
      expect(result.confidence).toBe(0.8);
    });

    it('should fallback to deploy detection', async () => {
      mockOllama.setShouldFail(true);

      const result = await classifier.classify('Задеплой приложение');

      expect(result.intent).toBe('deploy');
      expect(result.confidence).toBe(0.6);
    });

    it('should fallback to chat for unknown input', async () => {
      mockOllama.setShouldFail(true);

      const result = await classifier.classify('Просто сообщение');

      expect(result.intent).toBe('chat');
      expect(result.confidence).toBe(0.5);
    });
  });

  // ============================================================================
  // JSON Cleaning Tests
  // ============================================================================

  describe('JSON Response Cleaning', () => {
    it('should clean markdown code blocks', async () => {
      mockOllama.setMockResponse('```json\n{"intent": "chat", "confidence": 0.8}\n```');

      const result = await classifier.classify('Привет');

      expect(result.intent).toBe('chat');
      expect(result.confidence).toBe(0.8);
    });

    it('should clean markdown with json specifier', async () => {
      mockOllama.setMockResponse('```json\n{"intent": "help", "confidence": 0.9}\n```');

      const result = await classifier.classify('Помощь');

      expect(result.intent).toBe('help');
      expect(result.confidence).toBe(0.9);
    });

    it('should handle plain JSON', async () => {
      mockOllama.setMockResponse('{"intent": "status", "confidence": 0.85}');

      const result = await classifier.classify('Статус');

      expect(result.intent).toBe('status');
      expect(result.confidence).toBe(0.85);
    });
  });

  // ============================================================================
  // Factory Function Tests
  // ============================================================================

  describe('Factory Function', () => {
    it('should create classifier with defaults', () => {
      const factoryClassifier = createIntentClassifier();

      expect(factoryClassifier).toBeDefined();
      expect(factoryClassifier.getConfidenceThreshold()).toBe(0.7);
    });

    it('should create classifier with custom config', () => {
      const factoryClassifier = createIntentClassifier({
        confidenceThreshold: 0.5,
      });

      expect(factoryClassifier.getConfidenceThreshold()).toBe(0.5);
    });
  });

  // ============================================================================
  // Integration Tests (End-to-End)
  // ============================================================================

  describe('Integration Scenarios', () => {
    it('should handle Russian create_project request', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'create_project',
        confidence: 0.95,
        parameters: { name: 'delivery-bot', archetype: 'telegram-bot' },
      }));

      const result = await classifier.classify('Создай телеграм бот для доставки');

      expect(result.intent).toBe('create_project');
      expect(result.parameters.name).toBe('delivery-bot');
      expect(result.parameters.archetype).toBe('telegram-bot');
    });

    it('should handle English status request', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'status',
        confidence: 0.88,
        parameters: {},
      }));

      const result = await classifier.classify("What's the system status?");

      expect(result.intent).toBe('status');
      expect(result.confidence).toBeGreaterThan(0.7);
    });

    it('should handle mixed language help request', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'help',
        confidence: 0.92,
        parameters: {},
      }));

      const result = await classifier.classify('Помоги пожалуйста');

      expect(result.intent).toBe('help');
    });

    it('should handle deploy with project name', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'deploy',
        confidence: 0.85,
        parameters: { project_name: 'web-api' },
      }));

      const result = await classifier.classify('Deploy web-api to production');

      expect(result.intent).toBe('deploy');
      expect(result.parameters.project_name).toBe('web-api');
    });

    it('should handle casual chat message', async () => {
      mockOllama.setMockResponse(JSON.stringify({
        intent: 'chat',
        confidence: 0.93,
        parameters: {},
      }));

      const result = await classifier.classify('Привет! Как твои дела?');

      expect(result.intent).toBe('chat');
      expect(result.confidence).toBeGreaterThan(0.7);
    });
  });
});
