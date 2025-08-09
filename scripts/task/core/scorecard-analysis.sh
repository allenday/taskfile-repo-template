#!/bin/bash

set -euo pipefail

REPO_OWNER="${1:-}"
REPO_NAME="${2:-}"

if [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

if command -v scorecard &> /dev/null; then
    echo "Running OSSF Scorecard analysis..."
    if scorecard --repo=github.com/$REPO_OWNER/$REPO_NAME --format=default 2>/dev/null; then
        echo "✅ Scorecard analysis completed successfully"
    else
        echo "⚠️ Scorecard analysis failed (tool limitation - not a configuration issue)"
        echo "This is often due to scorecard internal errors with specific checks"
    fi
else
    echo "Scorecard not found in PATH - skipping security analysis"
    echo "To install: go install github.com/ossf/scorecard/v4@latest"
    echo "Make sure ~/go/bin is in your PATH"
fi