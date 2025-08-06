#!/bin/bash
set -euo pipefail

echo "🌍 Checking GitHub environments..."

if ! command -v gh >/dev/null 2>&1; then
    echo "⚠️ GitHub CLI not installed - skipping environment check"
    exit 0
fi

# Check if authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI. Run: gh auth login"
    exit 1
fi

echo "📋 Repository environments:"
if environments=$(gh api repos/:owner/:repo/environments 2>/dev/null); then
    if echo "$environments" | jq -e '.environments | length > 0' >/dev/null 2>&1; then
        echo "$environments" | jq -r '.environments[].name' | while read -r env; do
            echo "✅ Environment: $env"
        done
    else
        echo "⚠️ No environments configured"
    fi
else
    echo "❌ Could not access repository environments"
    exit 1
fi

# Check for expected environments (passed as arguments)
# Create state file for downstream tasks
ENV_STATE_FILE="/tmp/task-env-state"
rm -f "$ENV_STATE_FILE"

if [ $# -gt 0 ]; then
    echo "📋 Checking for expected environments:"
    missing_envs=0
    existing_envs=""
    
    for expected_env in "$@"; do
        if echo "$environments" | jq -e --arg env "$expected_env" '.environments[] | select(.name == $env)' >/dev/null 2>&1; then
            echo "✅ Expected environment '$expected_env' found"
            existing_envs="$existing_envs $expected_env"
        else
            echo "❌ Expected environment '$expected_env' not found - run 'task setup-all-envs' to create"
            missing_envs=$((missing_envs + 1))
        fi
    done
    
    # Write state to file for downstream tasks
    echo "MISSING_ENVS=$missing_envs" > "$ENV_STATE_FILE"
    echo "EXISTING_ENVS=\"$existing_envs\"" >> "$ENV_STATE_FILE"
    echo "ALL_EXPECTED_ENVS=\"$*\"" >> "$ENV_STATE_FILE"
    
    if [ $missing_envs -gt 0 ]; then
        echo "⚠️ $missing_envs expected environment(s) missing (continuing for informational purposes)"
    fi
else
    # No environments to check
    echo "MISSING_ENVS=0" > "$ENV_STATE_FILE"
    echo "EXISTING_ENVS=\"\"" >> "$ENV_STATE_FILE"
    echo "ALL_EXPECTED_ENVS=\"\"" >> "$ENV_STATE_FILE"
fi

echo "✅ Environment check completed"