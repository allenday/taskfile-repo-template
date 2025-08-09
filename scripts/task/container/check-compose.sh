#!/bin/bash

set -euo pipefail

# Check Docker Compose availability
if docker compose version &> /dev/null; then
    echo "Docker Compose: available (built-in)"
elif command -v docker-compose &> /dev/null; then
    echo "Docker Compose: available (standalone)"
else
    echo "Docker Compose: not available"
fi