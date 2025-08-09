#!/bin/bash

set -euo pipefail

VENV_DIR="${1:-.venv}"

# Install Python dependencies based on what's available
echo "Installing Python dependencies..."

if [ -f requirements.txt ]; then
    echo "Installing from requirements.txt"
    "$VENV_DIR/bin/pip" install -r requirements.txt
fi

if [ -f requirements-dev.txt ]; then
    echo "Installing from requirements-dev.txt" 
    "$VENV_DIR/bin/pip" install -r requirements-dev.txt
fi

if [ -f pyproject.toml ]; then
    echo "Installing from pyproject.toml with dev dependencies"
    "$VENV_DIR/bin/pip" install -e ".[dev]"
fi

echo "Python dependencies installation completed"