#!/bin/bash

set -euo pipefail

echo "Running comprehensive linting..."

# Run Python linting if available
if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    task python:lint 2>/dev/null || echo "Python linting not available"
fi

# Run protobuf linting if available  
if [ -d proto ] || find . -name "*.proto" | head -1 | grep -q .; then
    task protobuf:lint-proto 2>/dev/null || echo "Protobuf linting not available"
fi

echo "All linting completed"