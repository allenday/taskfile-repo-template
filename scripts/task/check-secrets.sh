#!/bin/bash
set -euo pipefail

echo "🔑 Checking repository secrets..."

if ! command -v gh >/dev/null 2>&1; then
    echo "⚠️ GitHub CLI not installed - skipping secrets check"
    exit 0
fi

# Check if authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI. Run: gh auth login"
    exit 1
fi

# Check repository secrets
echo "📋 Repository secrets:"
if gh secret list 2>/dev/null; then
    echo "✅ Repository secrets accessible"
else
    echo "❌ Could not access repository secrets"
    exit 1
fi

# Check environment secrets using state from environment check
echo "📋 Environment secrets:"

# Read state from environment check
ENV_STATE_FILE="/tmp/task-env-state"
if [ -f "$ENV_STATE_FILE" ]; then
    source "$ENV_STATE_FILE"
    
    if [ "$MISSING_ENVS" -gt 0 ]; then
        echo "⚠️ Skipping environment secrets check - $MISSING_ENVS environments missing"
        echo "   Missing environments detected in previous check"
        echo "   Run 'task setup-all-envs' to create missing environments first"
        
        # Still check existing environments if any
        if [ -n "$EXISTING_ENVS" ]; then
            echo "📋 Checking secrets for existing environments only:"
            for env in $EXISTING_ENVS; do
                if gh secret list --env "$env" >/dev/null 2>&1; then
                    secret_count=$(gh secret list --env "$env" 2>/dev/null | wc -l)
                    echo "✅ Environment '$env' has $secret_count secrets configured"
                else
                    echo "⚠️ Environment '$env' exists but has no secrets"
                fi
            done
        fi
    else
        # All environments exist, check normally
        if [ $# -eq 0 ] && [ -n "$ALL_EXPECTED_ENVS" ]; then
            # Use environments from state if none passed directly
            set -- $ALL_EXPECTED_ENVS
        fi
        
        if [ $# -eq 0 ]; then
            echo "⚠️ No environments to check"
        else
            for env in "$@"; do
                if gh secret list --env "$env" >/dev/null 2>&1; then
                    secret_count=$(gh secret list --env "$env" 2>/dev/null | wc -l)
                    echo "✅ Environment '$env' has $secret_count secrets configured"
                else
                    echo "⚠️ Environment '$env' exists but has no secrets"
                fi
            done
        fi
    fi
    
    # Keep state file for other tasks - cleaned up by Task generates/sources mechanism
else
    echo "⚠️ No environment state found - checking environments as provided"
    if [ $# -eq 0 ]; then
        echo "⚠️ No environments provided to check"
    else
        # Fallback to original behavior
        if environments=$(gh api repos/:owner/:repo/environments 2>/dev/null); then
            existing_envs=$(echo "$environments" | jq -r '.environments[].name' 2>/dev/null)
            
            for env in "$@"; do
                if echo "$existing_envs" | grep -q "^$env$"; then
                    if gh secret list --env "$env" >/dev/null 2>&1; then
                        secret_count=$(gh secret list --env "$env" 2>/dev/null | wc -l)
                        echo "✅ Environment '$env' has $secret_count secrets configured"
                    else
                        echo "⚠️ Environment '$env' exists but has no secrets"
                    fi
                else
                    echo "❌ Environment '$env' does not exist - run 'task setup-all-envs' to create"
                fi
            done
        else
            echo "❌ Could not access repository environments"
        fi
    fi
fi

echo "✅ Secrets check completed"