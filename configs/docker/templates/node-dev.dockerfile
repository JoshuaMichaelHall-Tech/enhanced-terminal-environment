FROM node:18-slim

# Set environment variables
ENV NODE_ENV=development \
    NPM_CONFIG_LOGLEVEL=warn

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    vim \
    less \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install global Node.js packages
RUN npm install -g \
    nodemon \
    typescript \
    ts-node \
    eslint \
    prettier \
    jest \
    npm-check-updates \
    http-server

# Install Yarn
RUN npm install -g yarn

# Create non-root user for better security
RUN groupadd -g 1000 nodeuser && \
    useradd -u 1000 -g nodeuser -s /bin/bash -m nodeuser

# Set ownership
RUN mkdir -p /app/node_modules && \
    chown -R nodeuser:nodeuser /app

# Switch to non-root user
USER nodeuser

# Set npm configurations
RUN npm config set save-exact true && \
    npm config set fund false

# Create configuration for volta (optional node version manager)
RUN mkdir -p /home/nodeuser/.volta && \
    chown -R nodeuser:nodeuser /home/nodeuser/.volta

# Make sure global packages are in path
ENV PATH="/home/nodeuser/.npm-global/bin:${PATH}"

# Create volume for persistent data
VOLUME ["/app"]

# Expose common development ports
EXPOSE 3000 8000 8080

# Default command
CMD ["bash"]

# Usage instructions
# Build: docker build -t node-dev -f node-dev.dockerfile .
# Run: docker run -it --rm -v $(pwd):/app -p 3000:3000 node-dev
