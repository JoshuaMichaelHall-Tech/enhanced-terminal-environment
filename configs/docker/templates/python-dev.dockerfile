FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    vim \
    less \
    openssh-client \
    postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel \
    && pip install poetry

# Set poetry configuration
RUN poetry config virtualenvs.create false

# Install development tools
RUN pip install \
    black \
    flake8 \
    pylint \
    pytest \
    pytest-cov \
    ipython \
    httpie

# Copy application code (when using this Dockerfile)
# COPY . /app/

# Create non-root user for better security
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -s /bin/bash -m appuser

# Set ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Add local bin to PATH
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Create volume for persistent data
VOLUME ["/app"]

# Default command
CMD ["bash"]

# Usage instructions
# Build: docker build -t python-dev -f python-dev.dockerfile .
# Run: docker run -it --rm -v $(pwd):/app python-dev
