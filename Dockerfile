# syntax=docker/dockerfile:1.9
FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv using the installer script
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Add uv to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Configure uv for optimal Docker usage with retry settings
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never \
    MCP_SERVER_HOST="0.0.0.0" \
    PYTHONUNBUFFERED=1 \
    DOCKER_ENV=1 \
    UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
    UV_TIMEOUT=300 \
    UV_RETRIES=5

# Create non-root user
RUN groupadd -r app && useradd -r -d /app -g app app

# Copy project files for dependency installation (better caching)
COPY --chown=app:app pyproject.toml uv.lock ./

# Copy the packages needed for MCP server and manager backend
COPY --chown=app:app ./config /app/config
COPY --chown=app:app ./graphiti_pro_core /app/graphiti_pro_core
COPY --chown=app:app ./manager/backend /app/backend
COPY --chown=app:app ./utils /app/utils

# Install dependencies as root (for system permissions)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Copy the main server file with proper ownership
COPY --chown=app:app main.py ./

# Create database directory with proper permissions
RUN mkdir -p /app/db && chown -R app:app /app/db
# Create cache directory for uv with proper permissions  
RUN mkdir -p /app/.cache && chown -R app:app /app/.cache

# Change ownership of the entire app directory
RUN chown -R app:app /app

# Expose MCP server port
EXPOSE 8000

# Command to run the MCP server with manager backend
CMD ["uv", "run", "main.py", "-m"]
