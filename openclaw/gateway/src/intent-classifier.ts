/**
 * Intent Classifier - AI-Powered Intent Recognition
 *
 * Classifies user messages into intents using gemini-3-flash-preview.
 * Replaces keyword matching with true NLP understanding.
 *
 * @see Expert Consilium v2.0 Report (ORCH-007.5 fix)
 * @see docs/analysis/2026-02-11-openclaw-expert-consilium-report.md
 */

import { OllamaClient, OllamaMessage } from './ollama-client';

// ============================================================================
// TYPES
// ============================================================================

export type IntentType = 'create_project' | 'status' | 'help' | 'deploy' | 'chat';

export interface IntentResult {
  intent: IntentType;
  confidence: number;
  parameters?: Record<string, any>;
}

export interface IntentClassifierConfig {
  ollamaClient: OllamaClient;
  systemPrompt?: string;
  temperature?: number;
  confidenceThreshold?: number;
}

// ============================================================================
// SYSTEM PROMPT
// ============================================================================

const INTENT_CLASSIFIER_SYSTEM_PROMPT = `You are an Intent Classifier for OpenClaw Gateway. Analyze user messages and return JSON.

Supported intents:
1. create_project — User wants to create a new project/application/bot
   - Examples: "Создай приложение", "Хочу новый бот", "Make project X"
   - Parameters: name (string), archetype (optional: web-service|telegram-bot|ai-agent|fullstack|cli-tool)

2. status — User wants to know system/project status
   - Examples: "Какой статус?", "Покажи состояние", "What's status"
   - Parameters: none

3. help — User asks for help or guidance
   - Examples: "Помощь", "Что ты умеешь?", "Help me"
   - Parameters: none

4. deploy — User wants to deploy something
   - Examples: "Задеплой", "Deploy app", "Запусти в прод"
   - Parameters: project_name (optional)

5. chat — General conversation or questions not related to commands
   - Examples: "Привет", "Как дела?", "Расскажи про AI", "Спасибо"
   - Parameters: none

Response format (JSON only, no markdown):
{
  "intent": "create_project|status|help|deploy|chat",
  "confidence": 0.0-1.0,
  "parameters": {...}
}

Rules:
- confidence >= 0.7: high confidence, proceed with command
- confidence 0.5-0.7: medium confidence, extract parameters but may ask for clarification
- confidence < 0.5: low confidence, treat as chat intent
- Extract all relevant parameters from user message
- Return ONLY valid JSON, no explanation text`;

// ============================================================================
// INTENT CLASSIFIER CLASS
// ============================================================================

export class IntentClassifier {
  private ollama: OllamaClient;
  private systemPrompt: string;
  private temperature: number;
  private confidenceThreshold: number;

  constructor(config: IntentClassifierConfig) {
    this.ollama = config.ollamaClient;
    this.systemPrompt = config.systemPrompt || INTENT_CLASSIFIER_SYSTEM_PROMPT;
    this.temperature = config.temperature || 0.1; // Low temperature for consistent classification
    this.confidenceThreshold = config.confidenceThreshold || 0.7;
  }

  /**
   * Classify user message into intent
   */
  async classify(message: string): Promise<IntentResult> {
    console.log(`[INTENT-CLASSIFIER] Classifying message: "${message.substring(0, 50)}..."`);

    try {
      const result = await this.classifyWithAI(message);
      console.log(`[INTENT-CLASSIFIER] AI result: ${result.intent} (confidence: ${result.confidence})`);

      // Validate confidence threshold
      if (result.confidence < this.confidenceThreshold && result.intent !== 'chat') {
        console.log(`[INTENT-CLASSIFIER] Low confidence (${result.confidence}), falling back to chat`);
        return {
          intent: 'chat',
          confidence: 1.0,
          parameters: {},
        };
      }

      return result;
    } catch (error) {
      console.error('[INTENT-CLASSIFIER] AI classification failed:', error);

      // Fallback to basic keyword detection
      return this.fallbackClassify(message);
    }
  }

  /**
   * Classify using AI (gemini-3-flash-preview)
   */
  private async classifyWithAI(message: string): Promise<IntentResult> {
    const messages: OllamaMessage[] = [
      { role: 'system', content: this.systemPrompt },
      { role: 'user', content: message },
    ];

    const response = await this.ollama.chat(messages, {
      temperature: this.temperature,
      format: 'json', // Request JSON format from Ollama
    });

    // Clean and parse response
    const cleanedResponse = this.cleanJSONResponse(response);
    const parsed = JSON.parse(cleanedResponse) as IntentResult;

    // Validate response structure
    if (!parsed.intent || typeof parsed.confidence !== 'number') {
      throw new Error('Invalid AI response: missing intent or confidence');
    }

    // Validate intent type
    const validIntents: IntentType[] = ['create_project', 'status', 'help', 'deploy', 'chat'];
    if (!validIntents.includes(parsed.intent)) {
      throw new Error(`Invalid intent: ${parsed.intent}`);
    }

    // Ensure parameters object exists
    if (!parsed.parameters) {
      parsed.parameters = {};
    }

    return parsed;
  }

  /**
   * Clean JSON response from AI (remove markdown code blocks if present)
   */
  private cleanJSONResponse(response: string): string {
    let cleaned = response.trim();

    // Remove markdown code blocks
    if (cleaned.startsWith('```')) {
      const lines = cleaned.split('\n');
      // Remove first line (```json or ```)
      lines.shift();
      // Remove last line if it's ```
      if (lines[lines.length - 1].trim() === '```') {
        lines.pop();
      }
      cleaned = lines.join('\n').trim();
    }

    return cleaned;
  }

  /**
   * Fallback keyword-based classification (used when AI fails)
   */
  private fallbackClassify(message: string): IntentResult {
    const lowerMessage = message.toLowerCase();

    // create_project patterns
    const createPatterns = [
      /(?:созда|create|сделай|generate|хочу)\s*(.*)?\s*(?:проект|project|приложение|app|бот|bot)/i,
    ];
    for (const pattern of createPatterns) {
      if (pattern.test(message)) {
        console.log('[INTENT-CLASSIFIER] Fallback: matched create_project pattern');
        return {
          intent: 'create_project',
          confidence: 0.6,
          parameters: this.extractCreateParams(message),
        };
      }
    }

    // status patterns
    const statusPatterns = [
      /статус|status|состояние|state|как дела|что происходит/i,
    ];
    for (const pattern of statusPatterns) {
      if (pattern.test(message)) {
        console.log('[INTENT-CLASSIFIER] Fallback: matched status pattern');
        return {
          intent: 'status',
          confidence: 0.7,
          parameters: {},
        };
      }
    }

    // help patterns
    const helpPatterns = [
      /помощь|help|справка|что ты умеешь|как использовать|команд/i,
    ];
    for (const pattern of helpPatterns) {
      if (pattern.test(message)) {
        console.log('[INTENT-CLASSIFIER] Fallback: matched help pattern');
        return {
          intent: 'help',
          confidence: 0.8,
          parameters: {},
        };
      }
    }

    // deploy patterns
    const deployPatterns = [
      /деплой|deploy|запуск|запусти|опубликовать|publish/i,
    ];
    for (const pattern of deployPatterns) {
      if (pattern.test(message)) {
        console.log('[INTENT-CLASSIFIER] Fallback: matched deploy pattern');
        return {
          intent: 'deploy',
          confidence: 0.6,
          parameters: {},
        };
      }
    }

    // Default to chat
    console.log('[INTENT-CLASSIFIER] Fallback: no pattern matched, defaulting to chat');
    return {
      intent: 'chat',
      confidence: 0.5,
      parameters: {},
    };
  }

  /**
   * Extract create_project parameters from message (fallback)
   */
  private extractCreateParams(message: string): Record<string, any> {
    const params: Record<string, any> = {};

    // Extract name (basic pattern matching)
    const namePatterns = [
      /(?:проект|project|app|бот|bot)\s+["']?([a-z0-9-_]+)["']?/i,
      /(?:созда|create)\s+(?:.*?)?\s+(?:назван|named|name)?\s+["']?([a-z0-9-_]+)["']?/i,
    ];

    for (const pattern of namePatterns) {
      const match = message.match(pattern);
      if (match && match[1]) {
        params.name = match[1];
        break;
      }
    }

    // Extract archetype
    const archetypes = ['web-service', 'telegram-bot', 'ai-agent', 'fullstack', 'cli-tool'];
    const lowerMessage = message.toLowerCase();

    for (const archetype of archetypes) {
      if (lowerMessage.includes(archetype)) {
        params.archetype = archetype;
        break;
      }
    }

    return params;
  }

  /**
   * Get confidence threshold
   */
  getConfidenceThreshold(): number {
    return this.confidenceThreshold;
  }

  /**
   * Set confidence threshold
   */
  setConfidenceThreshold(threshold: number): void {
    if (threshold < 0 || threshold > 1) {
      throw new Error('Confidence threshold must be between 0 and 1');
    }
    this.confidenceThreshold = threshold;
  }
}

// ============================================================================
// FACTORY FUNCTION
// ============================================================================

/**
 * Create Intent Classifier with default Ollama client
 */
export function createIntentClassifier(config?: Partial<IntentClassifierConfig>): IntentClassifier {
  const { createOllamaClient } = require('./ollama-client');

  return new IntentClassifier({
    ollamaClient: config?.ollamaClient || createOllamaClient(),
    systemPrompt: config?.systemPrompt,
    temperature: config?.temperature,
    confidenceThreshold: config?.confidenceThreshold,
  });
}
