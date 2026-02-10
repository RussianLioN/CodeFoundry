# ═════════════════════════════════════════════════════════════════════════════
# Multi-stage Dockerfile for CLI Tool
# ═══════════════════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────────────────────
# Stage 1: Build (Go)
# ────────────────────────────────────────────────────────────────────────────────
FROM golang:1.21-alpine AS builder-go

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache git ca-certificates

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build binary
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w -X main.version=${VERSION:-dev} -X main.commit=${COMMIT:-unknown}" \
    -a -installsuffix cgo \
    -o mycli .

# ────────────────────────────────────────────────────────────────────────────────
# Stage 2: Build (Python)
# ────────────────────────────────────────────────────────────────────────────────
FROM python:3.11-slim AS builder-python

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY pyproject.toml requirements.txt ./
RUN pip install --user --no-cache-dir .

# Copy source code
COPY . .

# ────────────────────────────────────────────────────────────────────────────────
# Stage 3: Final Runtime
# ────────────────────────────────────────────────────────────────────────────────
FROM alpine:3.19 AS final

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    bash \
    git \
    openssh-client

# Copy binary from Go builder
COPY --from=builder-go /build/mycli /usr/local/bin/mycli

# OR copy from Python builder
# COPY --from=builder-python /root/.local /root/.local
# ENV PATH=/root/.local/bin:$PATH

# Create entrypoint
ENTRYPOINT ["mycli"]

# Default command
CMD ["--help"]

# Metadata
LABEL org.opencontainers.image.title="My CLI Tool"
LABEL org.opencontainers.image.description="A professional CLI tool"
LABEL org.opencontainers.image.version="${VERSION}"
