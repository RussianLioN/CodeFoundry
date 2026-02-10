/**
 * Command Executor - CLI Bridge Integration
 *
 * Executes commands via CLI Bridge (claude-wrapper.sh).
 * Handles Command Protocol v1.0 JSON communication.
 *
 * @see docs/commands/PROTOCOL-v1.md
 * @see server/scripts/claude-wrapper.sh
 */
export interface CommandRequest {
    version: string;
    id: string;
    timestamp: string;
    command: string;
    params: Record<string, any>;
    context?: {
        user_id?: string;
        session_id?: string;
        request_id?: string;
    };
}
export interface CommandResponse {
    version: string;
    id: string;
    status: 'success' | 'error';
    result?: any;
    message?: string;
    error?: {
        code: string;
        message: string;
        details?: any;
    };
    timestamp: string;
}
export interface ExecutorConfig {
    cliWrapperPath?: string;
    claudeCodeContainer?: string;
    timeout?: number;
    workspace?: string;
}
export declare class CommandExecutor {
    private cliWrapperPath;
    private claudeCodeContainer;
    private timeout;
    private workspace;
    constructor(config?: ExecutorConfig);
    /**
     * Execute command via CLI Bridge
     */
    execute(request: CommandRequest): Promise<CommandResponse>;
    /**
     * Execute command with progress callback
     */
    executeWithProgress(request: CommandRequest, onProgress: (stage: string, progress: number, message: string) => void): Promise<CommandResponse>;
    /**
     * Validate command request
     */
    private validateRequest;
    /**
     * Build shell command for CLI Bridge
     */
    private buildCommand;
    /**
     * Parse CLI Bridge response
     */
    private parseResponse;
    /**
     * Create error response
     */
    private errorResponse;
    /**
     * Map error message to error code
     */
    private errorCodeFromMessage;
    /**
     * Validate CLI wrapper exists and is executable
     */
    private validateCliWrapper;
    /**
     * Test CLI Bridge connection
     */
    testConnection(): Promise<boolean>;
    /**
     * Get executor statistics
     */
    getStats(): {
        cliWrapperPath: string;
        claudeCodeContainer: string;
        workspace: string;
        timeout: number;
    };
}
/**
 * Create Command Executor with default configuration
 */
export declare function createCommandExecutor(config?: ExecutorConfig): CommandExecutor;
/**
 * Create Command Executor for remote execution
 */
export declare function createRemoteCommandExecutor(): CommandExecutor;
//# sourceMappingURL=command-executor.d.ts.map