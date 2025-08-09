#!/bin/bash

set -euo pipefail

echo "Formatting all code..."

# Format Python code if available
if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    task python:format 2>/dev/null || echo "Python formatting not available"
fi

# Format protobuf files if available
if [ -d proto ] || find . -name "*.proto" | head -1 | grep -q .; then
    task protobuf:format-proto 2>/dev/null || echo "Protobuf formatting not available"
fi

echo "All formatting completed"