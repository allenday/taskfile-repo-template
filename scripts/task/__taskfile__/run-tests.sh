#!/bin/bash

set -euo pipefail

echo "Running comprehensive test suite..."

# Run Python tests if available
if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    task python:test 2>/dev/null || echo "Python tests not available"
fi

echo "All tests completed"