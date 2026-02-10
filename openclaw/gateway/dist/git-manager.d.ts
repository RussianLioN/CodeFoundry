/**
 * Git Manager for OpenClaw Gateway
 *
 * Handles automatic Git operations for projects:
 * - Initialize repository
 * - Create commits
 * - Push to GitHub
 * - Create repositories via API
 */
export interface GitConfig {
    userName?: string;
    userEmail?: string;
    autoPush?: boolean;
    commitOnChange?: boolean;
}
export interface CommitOptions {
    type?: 'feat' | 'fix' | 'refactor' | 'docs' | 'test' | 'chore' | 'ai';
    message: string;
    files?: string[];
    body?: string;
    refs?: string;
}
export interface GitHubRepoOptions {
    name: string;
    description?: string;
    private?: boolean;
    autoInit?: boolean;
    gitignoreTemplate?: string;
}
export interface GitHubCreateResult {
    id: number;
    name: string;
    fullName: string;
    cloneUrl: string;
    sshUrl: string;
    htmlUrl: string;
}
export declare class GitManager {
    private config;
    constructor(config?: GitConfig);
    /**
     * Initialize Git repository in project directory
     */
    init(projectPath: string): Promise<void>;
    /**
     * Create initial commit for new project
     */
    initialCommit(projectPath: string, metadata: {
        type: string;
        name: string;
    }): Promise<string>;
    /**
     * Create a commit with changes
     */
    commit(projectPath: string, options: CommitOptions): Promise<string>;
    /**
     * Push changes to remote
     */
    push(projectPath: string, branch?: string, options?: string[]): Promise<void>;
    /**
     * Pull changes from remote
     */
    pull(projectPath: string, branch?: string): Promise<void>;
    /**
     * Add remote repository
     */
    addRemote(projectPath: string, url: string, name?: string): Promise<void>;
    /**
     * Create GitHub repository via API
     */
    createGitHubRepo(options: GitHubRepoOptions, githubToken: string): Promise<GitHubCreateResult>;
    /**
     * Get repository status
     */
    getStatus(projectPath: string): Promise<{
        branch: string;
        ahead: number;
        behind: number;
        staged: number;
        unstaged: number;
        untracked: number;
    }>;
    /**
     * Execute git command in directory
     */
    private exec;
    /**
     * Build commit message from options
     */
    private buildCommitMessage;
    /**
     * Get default .gitignore content
     */
    private getDefaultGitignore;
}
export declare function getGitManager(): GitManager;
export default GitManager;
//# sourceMappingURL=git-manager.d.ts.map