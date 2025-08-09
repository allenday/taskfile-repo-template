#!/bin/bash

set -euo pipefail

echo "Setting up language-specific environments..."

if [ -f requirements.txt ] || [ -f pyproject.toml ] || [ -f setup.py ]; then
    echo "Python project detected - setting up Python environment"
    task python:setup-python 2>/dev/null || echo "Python tasks not available"
fi