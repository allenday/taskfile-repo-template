#!/bin/bash

set -euo pipefail

echo "Cleaning Python build artifacts and cache..."

# Remove Python cache files and directories
find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true

# Remove build artifacts
rm -rf build/ dist/ *.egg-info/ .pytest_cache/ .coverage htmlcov/

# Remove security report files
rm -f bandit-report.json safety-report.json

echo "Python artifacts cleaned"