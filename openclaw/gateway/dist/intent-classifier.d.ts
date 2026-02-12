/**
 * Intent Classifier - AI-Powered Intent Recognition
 *
 * Classifies user messages into intents using gemini-3-flash-preview.
 * Replaces keyword matching with true NLP understanding.
 *
 * @see Expert Consilium v2.0 Report (ORCH-007.5 fix)
 * @see docs/analysis/2026-02-11-openclaw-expert-consilium-report.md
 */
import { OllamaClient } from './ollama-client';
export type IntentType = 'create_project' | 'status' | 'help' | 'deploy' | 'chat' | 'small_talk';
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
export declare class IntentClassifier {
    private ollama;
    private systemPrompt;
    private temperature;
    private confidenceThreshold;
    constructor(config: IntentClassifierConfig);
    /**
     * Classify user message into intent
     */
    classify(message: string): Promise<IntentResult>;
    /**
     * Classify using AI (gemini-3-flash-preview)
     */
    private classifyWithAI;
    /**
     * Clean JSON response from AI (remove markdown code blocks if present)
     */
    private cleanJSONResponse;
    /**
     * Fallback keyword-based classification (used when AI fails)
     */
    private fallbackClassify;
    /**
     * Extract create_project parameters from message (fallback)
     */
    private extractCreateParams;
    /**
     * Get confidence threshold
     */
    getConfidenceThreshold(): number;
    /**
     * Set confidence threshold
     */
    setConfidenceThreshold(threshold: number): void;
}
/**
 * Create Intent Classifier with default Ollama client
 */
export declare function createIntentClassifier(config?: Partial<IntentClassifierConfig>): IntentClassifier;
//# sourceMappingURL=intent-classifier.d.ts.map