#!/bin/bash

set -euo pipefail

echo "Setting up language-specific environments..."

# Python detection
if [ -f requirements.txt ] || [ -f pyproject.toml ] || [ -f setup.py ]; then
    echo "Python project detected - setting up Python environment"
    task python:setup-python 2>/dev/null || echo "Python tasks not available"
fi

# Solidity detection
if [ -f foundry.toml ] || [ -d src ] && find src -name "*.sol" 2>/dev/null | grep -q .; then
    echo "Solidity project detected - setting up Solidity environment"
    task solidity:setup 2>/dev/null || echo "Solidity tasks not available"
fi