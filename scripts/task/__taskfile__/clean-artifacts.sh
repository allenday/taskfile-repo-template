#!/bin/bash

set -euo pipefail

SCORECARD_RESULTS="${1:-scorecard-results.json}"

echo "Cleaning all artifacts..."

# Clean Python artifacts if available
if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    task python:clean 2>/dev/null || echo "Python cleanup not available"
fi

# Clean protobuf artifacts if available
if [ -d proto ] || find . -name "*.proto" | head -1 | grep -q .; then
    task protobuf:clean-all 2>/dev/null || echo "Protobuf cleanup not available"
fi

# Clean core artifacts
rm -f "$SCORECARD_RESULTS"
rm -f report.md

echo "All cleanup completed"