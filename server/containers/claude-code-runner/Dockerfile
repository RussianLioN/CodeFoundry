# =============================================================================
# Claude Code Runner - CLI Bridge Target Container
# =============================================================================
# Purpose: Provides isolated environment for executing CLI Bridge commands
#
# Features:
#   - jq: JSON parsing for Command Protocol v1.0
#   - Docker CLI: Docker-in-Docker capability
#   - bash: Shell for executing claude-wrapper.sh
#   - Alpine-based: Minimal image size
#
# Usage:
#   docker build -t claude-code-runner:latest .
#   docker-compose -f docker-compose.orchestrator.yml up -d
# =============================================================================

FROM alpine:3.19

# Metadata
LABEL maintainer="CodeFoundry"
LABEL description="Claude Code Runner - CLI Bridge Target"
LABEL version="1.0.0"
LABEL com.openclaw.service="claude-code-runner"

# Install required packages (use latest versions from Alpine 3.19)
RUN apk add --no-cache \
    # JSON processing (required for Command Protocol v1.0)
    jq \
    # Docker CLI (for Docker-in-Docker capability)
    docker-cli \
    # Bash shell (for claude-wrapper.sh execution)
    bash \
    # Curl for health checks
    curl \
    # Process management
    procps-ng

# Create directory for CLI Bridge scripts
# Note: claude-wrapper.sh is mounted via volume in docker-compose
RUN mkdir -p /opt/claude-bridge

# Create workspace directory
RUN mkdir -p /workspace

# Set working directory
WORKDIR /workspace

# Create non-root user for security
RUN addgroup -g 1000 claude && \
    adduser -D -u 1000 -G claude claude

# Set ownership of workspace
# Note: /opt/claude-bridge is a volume mount, ownership handled at runtime
RUN chown -R claude:claude /workspace

# Switch to non-root user
USER claude

# Environment variables
ENV NODE_ENV=development \
    WORKSPACE_DIR=/workspace \
    PROJECT_DIR=/workspace \
    CLI_WRAPPER_PATH=/opt/claude-bridge/claude-wrapper.sh \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Health check - check for workspace accessibility
# Note: CodeFoundry is a meta-project, not a Node.js project
HEALTHCHECK --interval=30s --timeout=5s --retries=2 --start-period=10s \
    CMD sh -c 'test -d /workspace && test -f /workspace/PROJECT.md'

# Default command: keep container running
# The container will execute commands via CLI Bridge (claude-wrapper.sh)
CMD ["tail", "-f", "/dev/null"]
