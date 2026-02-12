"use strict";
/**
 * Command Executor - CLI Bridge Integration
 *
 * Executes commands via CLI Bridge (claude-wrapper.sh).
 * Handles Command Protocol v1.0 JSON communication.
 *
 * @see docs/commands/PROTOCOL-v1.md
 * @see server/scripts/claude-wrapper.sh
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.CommandExecutor = void 0;
exports.createCommandExecutor = createCommandExecutor;
exports.createRemoteCommandExecutor = createRemoteCommandExecutor;
const child_process_1 = require("child_process");
const util_1 = require("util");
const execAsync = (0, util_1.promisify)(child_process_1.exec);
// ============================================================================
// COMMAND EXECUTOR CLASS
// ============================================================================
class CommandExecutor {
    cliWrapperPath;
    claudeCodeContainer;
    timeout;
    workspace;
    constructor(config = {}) {
        // CLI Bridge path (check env var first, then config, then default)
        this.cliWrapperPath = config.cliWrapperPath ||
            process.env.CLI_WRAPPER_PATH ||
            `${process.env.REMOTE_GIT_REPO || './server'}/scripts/claude-wrapper.sh`;
        // Claude Code container name
        this.claudeCodeContainer = config.claudeCodeContainer ||
            process.env.CLAUDE_CODE_CONTAINER ||
            'claude-code-runner';
        // Command timeout (default: 2 minutes)
        this.timeout = config.timeout || 120000;
        // Workspace directory
        this.workspace = config.workspace || process.env.WORKSPACE || process.cwd();
        // Validate CLI wrapper exists
        this.validateCliWrapper();
    }
    /**
     * Execute command via CLI Bridge
     */
    async execute(request) {
        const startTime = Date.now();
        try {
            // Validate request
            this.validateRequest(request);
            // Log execution
            console.log(`[EXECUTOR] Executing: ${request.command} (${request.id})`);
            // Build command
            const command = this.buildCommand(request);
            // Execute via CLI Bridge
            const { stdout, stderr } = await execAsync(command, {
                timeout: this.timeout,
                env: {
                    ...process.env,
                    CLI_WRAPPER: this.cliWrapperPath,
                    CLAUDE_CODE_CONTAINER: this.claudeCodeContainer,
                    WORKSPACE: this.workspace,
                },
            });
            // Parse response
            const response = this.parseResponse(stdout);
            // Log duration
            const duration = Date.now() - startTime;
            console.log(`[EXECUTOR] Completed: ${request.command} (${duration}ms)`);
            return response;
        }
        catch (error) {
            // Handle execution error
            const duration = Date.now() - startTime;
            console.error(`[EXECUTOR] Failed: ${request.command} (${duration}ms)`, error.message);
            return this.errorResponse(request, error);
        }
    }
    /**
     * Execute command with progress callback
     */
    async executeWithProgress(request, onProgress) {
        // For now, use standard execute
        // TODO: Implement streaming progress from CLI Bridge
        onProgress('executing', 50, `Executing ${request.command}...`);
        const response = await this.execute(request);
        onProgress('complete', 100, 'Complete');
        return response;
    }
    /**
     * Validate command request
     */
    validateRequest(request) {
        // Check version
        if (request.version !== '1.0') {
            throw new Error(`Unsupported protocol version: ${request.version}`);
        }
        // Check required fields
        if (!request.id) {
            throw new Error('Missing required field: id');
        }
        if (!request.command) {
            throw new Error('Missing required field: command');
        }
        // Validate command name
        const validCommands = ['create_project', 'status', 'help'];
        if (!validCommands.includes(request.command)) {
            throw new Error(`Unknown command: ${request.command}`);
        }
    }
    /**
     * Build shell command for CLI Bridge
     */
    buildCommand(request) {
        // Escape JSON for shell
        const jsonPayload = JSON.stringify(request)
            .replace(/"/g, '\\"')
            .replace(/\n/g, '\\n');
        // Build command
        return `echo "${jsonPayload}" | "${this.cliWrapperPath}"`;
    }
    /**
     * Parse CLI Bridge response
     */
    parseResponse(output) {
        try {
            // Extract JSON from output (might have leading/trailing text)
            const jsonMatch = output.match(/\{[\s\S]*\}/);
            if (!jsonMatch) {
                throw new Error('No JSON found in output');
            }
            const parsed = JSON.parse(jsonMatch[0]);
            // Validate response structure
            if (!parsed.version || !parsed.status) {
                throw new Error('Invalid response structure');
            }
            return parsed;
        }
        catch (error) {
            console.error('[EXECUTOR] Parse error:', error);
            const errMsg = error instanceof Error ? error.message : String(error);
            throw new Error(`Failed to parse response: ${errMsg}`);
        }
    }
    /**
     * Create error response
     */
    errorResponse(request, error) {
        return {
            version: '1.0',
            id: request.id,
            status: 'error',
            error: {
                code: this.errorCodeFromMessage(error.message),
                message: error.message,
                details: {
                    command: request.command,
                    params: request.params,
                },
            },
            timestamp: new Date().toISOString(),
        };
    }
    /**
     * Map error message to error code
     */
    errorCodeFromMessage(message) {
        if (message.includes('ETIMEDOUT') || message.includes('timeout')) {
            return 'TIMEOUT';
        }
        if (message.includes('ENOENT') || message.includes('not found')) {
            return 'CLAUDE_CODE_ERROR';
        }
        if (message.includes('Unknown command')) {
            return 'UNKNOWN_COMMAND';
        }
        if (message.includes('Invalid params')) {
            return 'INVALID_PARAMS';
        }
        return 'CLAUDE_CODE_ERROR';
    }
    /**
     * Validate CLI wrapper exists and is executable
     */
    validateCliWrapper() {
        try {
            // Check if file exists
            const fs = require('fs');
            if (!fs.existsSync(this.cliWrapperPath)) {
                console.warn(`[EXECUTOR] CLI wrapper not found: ${this.cliWrapperPath}`);
                console.warn('[EXECUTOR] Commands will fail until CLI wrapper is available');
                return;
            }
            // Check if executable
            fs.accessSync(this.cliWrapperPath, fs.constants.X_OK);
            console.log(`[EXECUTOR] CLI wrapper: ${this.cliWrapperPath}`);
        }
        catch (error) {
            console.warn(`[EXECUTOR] CLI wrapper validation failed:`, error);
        }
    }
    /**
     * Test CLI Bridge connection
     */
    async testConnection() {
        try {
            const testRequest = {
                version: '1.0',
                id: 'test-connection',
                timestamp: new Date().toISOString(),
                command: 'help',
                params: {},
            };
            const response = await this.execute(testRequest);
            return response.status === 'success';
        }
        catch (error) {
            console.error('[EXECUTOR] Connection test failed:', error);
            return false;
        }
    }
    /**
     * Get executor statistics
     */
    getStats() {
        return {
            cliWrapperPath: this.cliWrapperPath,
            claudeCodeContainer: this.claudeCodeContainer,
            workspace: this.workspace,
            timeout: this.timeout,
        };
    }
}
exports.CommandExecutor = CommandExecutor;
// ============================================================================
// FACTORY FUNCTION
// ============================================================================
/**
 * Create Command Executor with default configuration
 */
function createCommandExecutor(config) {
    return new CommandExecutor(config);
}
/**
 * Create Command Executor for remote execution
 */
function createRemoteCommandExecutor() {
    return new CommandExecutor({
        cliWrapperPath: `${process.env.REMOTE_GIT_REPO || '/root/projects/CodeFoundry'}/server/scripts/claude-wrapper.sh`,
        claudeCodeContainer: 'claude-code-runner',
        workspace: process.env.WORKSPACE || '/workspace',
    });
}
//# sourceMappingURL=command-executor.js.map