# ═══════════════════════════════════════════════════════════════════════════════
# Multi-Stage Dockerfile for Web Service
# ═══════════════════════════════════════════════════════════════════════════════
# Optimized for production with minimal image size and security best practices
# ═══════════════════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────────────────────
# Stage 1: Builder
# ────────────────────────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

# Set build arguments
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source code
COPY src ./src

# Build application
RUN npm run build

# ────────────────────────────────────────────────────────────────────────────────
# Stage 2: Production Runtime
# ────────────────────────────────────────────────────────────────────────────────
FROM node:20-alpine AS runtime

# Install runtime dependencies
RUN apk add --no-cache \
    dumb-init \
    curl \
    ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist

# Set environment
ENV NODE_ENV=production \
    PORT=3000 \
    # Disable telemetry
    DISABLE_TELEMETRY=1

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "dist/main.js"]
