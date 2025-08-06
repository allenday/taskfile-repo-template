#!/bin/bash
set -euo pipefail

echo "🛡️ Checking branch protection..."

if ! command -v gh >/dev/null 2>&1; then
    echo "⚠️ GitHub CLI not installed - skipping branch protection check"
    exit 0
fi

# Check if authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI. Run: gh auth login"
    exit 1
fi

# Check main/master branch protection
for branch in "main" "master"; do
    echo "📋 Checking branch protection for '$branch'..."
    
    if protection=$(gh api repos/:owner/:repo/branches/$branch/protection 2>/dev/null); then
        echo "✅ Branch protection enabled for '$branch'"
        
        # Check specific protection rules
        if echo "$protection" | jq -e '.required_status_checks' >/dev/null 2>&1; then
            echo "  ✅ Required status checks enabled"
        else
            echo "  ⚠️ No required status checks"
        fi
        
        if echo "$protection" | jq -e '.enforce_admins.enabled' >/dev/null 2>&1; then
            if echo "$protection" | jq -r '.enforce_admins.enabled' | grep -q "true"; then
                echo "  ✅ Admin enforcement enabled"
            else
                echo "  ⚠️ Admin enforcement disabled"
            fi
        fi
        
        if echo "$protection" | jq -e '.required_pull_request_reviews' >/dev/null 2>&1; then
            echo "  ✅ Pull request reviews required"
        else
            echo "  ⚠️ No pull request review requirements"
        fi
        
        break
    else
        echo "❌ No branch protection found for '$branch'"
    fi
done

echo "✅ Branch protection check completed"