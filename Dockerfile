# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set environment variables
ENV NODE_VERSION=20

# Install Node.js
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and external-scripts.json
COPY package.json external-scripts.json ./

# Copy bin and scripts folders
COPY bin ./bin
COPY scripts ./scripts

# Install dependencies
RUN npm install

# Run the application
CMD ["bin/hubot", "-a", "@hubot-friends/hubot-slack"]