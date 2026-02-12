"use strict";
/**
 * Intent Classifier - AI-Powered Intent Recognition
 *
 * Classifies user messages into intents using gemini-3-flash-preview.
 * Replaces keyword matching with true NLP understanding.
 *
 * @see Expert Consilium v2.0 Report (ORCH-007.5 fix)
 * @see docs/analysis/2026-02-11-openclaw-expert-consilium-report.md
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.IntentClassifier = void 0;
exports.createIntentClassifier = createIntentClassifier;
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

5. small_talk — Greetings and simple phrases (HIGH PRIORITY for short messages)
   - Examples: "привет", "ping", "как дела", "спасибо", "hello", "hi", "thx"
   - Parameters: none
   - IMPORTANT: Return "small_talk" with confidence 1.0 for greetings and short pleasantries

6. chat — General conversation or questions not related to commands
   - Examples: "Расскажи про AI", "Что такое Docker?", "Explain microservices"
   - Parameters: none

Response format (JSON only, no markdown):
{
  "intent": "create_project|status|help|deploy|small_talk|chat",
  "confidence": 0.0-1.0,
  "parameters": {...}
}

Rules:
- small_talk: greetings, "ping", "thanks" → confidence 1.0
- confidence >= 0.7: high confidence, proceed with command
- confidence 0.5-0.7: medium confidence, extract parameters but may ask for clarification
- confidence < 0.5: low confidence, treat as chat intent
- Extract all relevant parameters from user message
- Return ONLY valid JSON, no explanation text`;
// ============================================================================
// INTENT CLASSIFIER CLASS
// ============================================================================
class IntentClassifier {
    ollama;
    systemPrompt;
    temperature;
    confidenceThreshold;
    constructor(config) {
        this.ollama = config.ollamaClient;
        this.systemPrompt = config.systemPrompt || INTENT_CLASSIFIER_SYSTEM_PROMPT;
        this.temperature = config.temperature || 0.1; // Low temperature for consistent classification
        this.confidenceThreshold = config.confidenceThreshold || 0.7;
    }
    /**
     * Classify user message into intent
     */
    async classify(message) {
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
        }
        catch (error) {
            console.error('[INTENT-CLASSIFIER] AI classification failed:', error);
            // Fallback to basic keyword detection
            return this.fallbackClassify(message);
        }
    }
    /**
     * Classify using AI (gemini-3-flash-preview)
     */
    async classifyWithAI(message) {
        const messages = [
            { role: 'system', content: this.systemPrompt },
            { role: 'user', content: message },
        ];
        const response = await this.ollama.chat(messages, {
            temperature: this.temperature,
            format: 'json', // Request JSON format from Ollama
        });
        // Clean and parse response
        const cleanedResponse = this.cleanJSONResponse(response);
        const parsed = JSON.parse(cleanedResponse);
        // Validate response structure
        if (!parsed.intent || typeof parsed.confidence !== 'number') {
            throw new Error('Invalid AI response: missing intent or confidence');
        }
        // Validate intent type
        const validIntents = ['create_project', 'status', 'help', 'deploy', 'chat', 'small_talk'];
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
    cleanJSONResponse(response) {
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
    fallbackClassify(message) {
        const lowerMessage = message.toLowerCase().trim();
        // small_talk patterns (check FIRST for short messages)
        // Greetings, "ping", "thanks" - very short messages
        const smallTalkPatterns = [
            /^(привет|здравствуй|hello|hi|hey|йо|дарова)$/i,
            /^(ping|pong|пинг|понг)$/i,
            /^(спасибо|благодарю|thanks|thx|ty|спс)$/i,
            /^(как дела|как ты|как жизнь|how are you|hows it going)$/i,
            /^(ок|окей|ага|понял|ясно|good|ok|okay)$/i,
            /^(пока|до свидания|bye|goodbye|покеда)$/i,
        ];
        for (const pattern of smallTalkPatterns) {
            if (pattern.test(message)) {
                console.log('[INTENT-CLASSIFIER] Fallback: matched small_talk pattern');
                return {
                    intent: 'small_talk',
                    confidence: 1.0,
                    parameters: {},
                };
            }
        }
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
    extractCreateParams(message) {
        const params = {};
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
    getConfidenceThreshold() {
        return this.confidenceThreshold;
    }
    /**
     * Set confidence threshold
     */
    setConfidenceThreshold(threshold) {
        if (threshold < 0 || threshold > 1) {
            throw new Error('Confidence threshold must be between 0 and 1');
        }
        this.confidenceThreshold = threshold;
    }
}
exports.IntentClassifier = IntentClassifier;
// ============================================================================
// FACTORY FUNCTION
// ============================================================================
/**
 * Create Intent Classifier with default Ollama client
 */
function createIntentClassifier(config) {
    const { createOllamaClient } = require('./ollama-client');
    return new IntentClassifier({
        ollamaClient: config?.ollamaClient || createOllamaClient(),
        systemPrompt: config?.systemPrompt,
        temperature: config?.temperature,
        confidenceThreshold: config?.confidenceThreshold,
    });
}
//# sourceMappingURL=intent-classifier.js.map