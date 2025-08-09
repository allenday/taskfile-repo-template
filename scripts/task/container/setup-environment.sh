#!/bin/bash

set -euo pipefail

# Setup container environment if detected
if ./scripts/task/container/detect-environment.sh >/dev/null 2>&1; then
    echo "Container environment detected - setting up container tools..."
    
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        brew install --cask docker || echo "Failed to install Docker - please install manually"
    fi
    
    if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        brew install docker-compose || echo "Failed to install Docker Compose"
    fi
    
    echo "Container setup completed"
else
    echo "No container environment detected - skipping container setup"
fi