# ═════════════════════════════════════════════════════════════════════════════
# Dockerfile for System Prompts Meta-Generator
# ═══════════════════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────────────────────
# Base image with utilities
# ────────────────────────────────────────────────────────────────────────────────
FROM alpine:3.19

# Install dependencies
RUN apk add --no-cache \
    bash \
    git \
    make \
    curl \
    ca-certificates \
    python3 \
    py3-pip \
    nodejs \
    npm \
    jq

# Set working directory
WORKDIR /system-prompts

# Copy project files
COPY . .

# Make scripts executable
RUN chmod +x scripts/*.sh

# Create directories
RUN mkdir -p /workspace

# Set up environment
ENV PATH="/system-prompts/scripts:${PATH}"
ENV SYSTEM_PROMPTS_HOME="/system-prompts"

# Volume for workspace
VOLUME ["/workspace"]

# Default command
CMD ["/bin/bash"]
