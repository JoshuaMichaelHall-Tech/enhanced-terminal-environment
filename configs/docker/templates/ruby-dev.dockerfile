FROM ruby:3.2-slim

# Set environment variables
ENV BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle \
    LANG=C.UTF-8 \
    GEM_HOME=/usr/local/bundle

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
    libpq-dev \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install -g yarn

# Install common gems
RUN gem update --system && \
    gem install bundler rails rake rspec rubocop solargraph pry

# Create non-root user for better security
RUN groupadd -g 1000 rubyuser && \
    useradd -u 1000 -g rubyuser -s /bin/bash -m rubyuser

# Configure bundler
RUN mkdir -p /usr/local/bundle && \
    chown -R rubyuser:rubyuser /usr/local/bundle

# Set ownership
RUN chown -R rubyuser:rubyuser /app

# Switch to non-root user
USER rubyuser

# Create volume for persistent data
VOLUME ["/app"]

# Expose common development ports
EXPOSE 3000 4000 5000

# Default command
CMD ["bash"]

# Usage instructions
# Build: docker build -t ruby-dev -f ruby-dev.dockerfile .
# Run: docker run -it --rm -v $(pwd):/app -p 3000:3000 ruby-dev
