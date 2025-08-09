#!/bin/bash
set -euo pipefail

echo "🛡️ Setting up branch protection rules..."

if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI not installed. Please install with: brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI. Run: gh auth login"
    exit 1
fi

# Determine the default branch
default_branch=$(gh api repos/:owner/:repo --jq '.default_branch')
echo "📋 Default branch detected: $default_branch"

echo "🔧 Setting up branch protection for: $default_branch"

# Create branch protection rule
protection_config='{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci", "test", "lint"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true
}'

if echo "$protection_config" | gh api repos/:owner/:repo/branches/$default_branch/protection --method PUT --input - >/dev/null 2>&1; then
    echo "✅ Branch protection rules applied to $default_branch"
    echo "📋 Protection rules configured:"
    echo "   🔍 Required status checks: ci, test, lint"
    echo "   👥 Required pull request reviews: 1"
    echo "   🔄 Dismiss stale reviews: enabled"
    echo "   💬 Require conversation resolution: enabled"
    echo "   🚫 Force pushes: disabled"
    echo "   🗑️ Branch deletion: disabled"
else
    echo "❌ Failed to apply branch protection rules"
    echo "⚠️ You may need admin permissions to set branch protection"
    echo "📝 Manual setup required:"
    echo "   1. Go to Settings → Branches in your GitHub repository"
    echo "   2. Add branch protection rule for '$default_branch'"
    echo "   3. Enable 'Require status checks to pass before merging'"
    echo "   4. Enable 'Require pull request reviews before merging'"
    echo "   5. Enable 'Require conversation resolution before merging'"
fi

# Check if there are any workflows that should be required status checks
if [ -d ".github/workflows" ]; then
    echo "📋 Available workflows for status checks:"
    find .github/workflows -name "*.yml" -o -name "*.yaml" | while read -r workflow; do
        workflow_name=$(basename "$workflow" .yml | sed 's/.yaml$//')
        echo "   📄 $workflow_name"
    done
    echo "💡 Consider adding these as required status checks in GitHub repository settings"
fi

echo "✅ Branch protection setup completed"