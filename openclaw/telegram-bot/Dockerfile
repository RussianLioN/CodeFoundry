# OpenClaw Telegram Bot Dockerfile
#
# Multi-stage build for optimal image size
#
# Usage:
#   docker build -t openclaw/telegram-bot:latest .
#   docker run -e TELEGRAM_BOT_TOKEN=xxx openclaw/telegram-bot

# ============================================================
# Stage 1: Dependencies
# ============================================================
FROM node:20-alpine AS dependencies

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    bash

# Copy package files
COPY package*.json ./
RUN npm install

# ============================================================
# Stage 2: Build
# ============================================================
FROM node:20-alpine AS build

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    bash

# Copy from dependencies stage
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/package*.json ./

# Copy source code
COPY src ./src
COPY tsconfig.json ./

# Build TypeScript
RUN npm run build

# ============================================================
# Stage 3: Production
# ============================================================
FROM node:20-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    bash

# Create app directory
WORKDIR /app

# Copy from build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/dist ./dist

# Create non-root user
RUN addgroup -g 1001 -S bot && \
    adduser -u 1001 -S bot -G bot

# Set working directory for user
RUN mkdir -p /home/bot/.npm && \
    chown -R bot:bot /home/bot/.npm && \
    mkdir -p /workspace && \
    chown -R bot:bot /workspace

USER bot

# Set environment
ENV NODE_ENV=production \
    TELEGRAM_BOT_TOKEN="" \
    GATEWAY_URL=ws://gateway:18789 \
    SESSION_TIMEOUT=3600000 \
    LOG_LEVEL=info

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD node -e "console.log('healthy')" || exit 1

# Start bot
CMD ["node", "dist/bot.js"]
