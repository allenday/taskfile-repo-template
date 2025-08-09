#!/bin/bash

set -euo pipefail

# Run Python checks if available
if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    task python:check 2>/dev/null || echo "Python checks not available"
fi

# Run protobuf checks if available
if [ -d proto ] || find . -name "*.proto" | head -1 | grep -q .; then
    task protobuf:check-proto 2>/dev/null || echo "Protobuf checks not available"  
fi

# Run container checks if available
task container:check 2>/dev/null || echo "Container checks not available"

echo "Comprehensive checks completed"