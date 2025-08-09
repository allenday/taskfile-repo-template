#!/bin/bash

set -euo pipefail

BWS_ACCESS_TOKEN="${BWS_ACCESS_TOKEN:-}"
BWS_PROJECT_ID="${BWS_PROJECT_ID:-}"

# Check Bitwarden Secrets Manager configuration
if [ -z "$BWS_ACCESS_TOKEN" ]; then
    echo "❌ BWS_ACCESS_TOKEN environment variable not set"
    echo "   Set it with: export BWS_ACCESS_TOKEN=your_token_here"
    exit 1
fi

if [ -z "$BWS_PROJECT_ID" ]; then
    echo "❌ BWS_PROJECT_ID environment variable not set"
    echo "   Set it with: export BWS_PROJECT_ID=your_project_id_here"
    exit 1
fi

if ! command -v bws >/dev/null 2>&1; then
    echo "❌ Bitwarden Secrets CLI (bws) not installed"
    echo "   Install from: https://bitwarden.com/help/secrets-manager-cli/"
    exit 1
fi

echo "✅ Bitwarden Secrets Manager properly configured"
echo "   Access Token: $(echo "$BWS_ACCESS_TOKEN" | head -c 8)..."
echo "   Project ID: $BWS_PROJECT_ID"