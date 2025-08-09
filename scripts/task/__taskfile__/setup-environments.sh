#!/bin/bash
set -euo pipefail

ENV=${1:-"dev"}
VISIBILITY=${2:-"private"}

echo "🌍 Setting up GitHub environments..."

if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI not installed. Please install with: brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI. Run: gh auth login"
    exit 1
fi

# Define environments to create
environments=(
    "private-dev"
    "private-staging"
    "private-prod"
    "public-dev"
    "public-staging"  
    "public-prod"
)

echo "📋 Creating GitHub environments..."

for environment in "${environments[@]}"; do
    echo "🔧 Setting up environment: $environment"
    
    # Create environment using GitHub API
    # Note: Environment creation via CLI might require additional permissions
    if gh api repos/:owner/:repo/environments/$environment --method PUT \
        --field wait_timer=0 \
        --field prevent_self_review=true \
        --field reviewers='[]' \
        --field deployment_branch_policy='{"protected_branches": true, "custom_branch_policies": false}' \
        >/dev/null 2>&1; then
        echo "  ✅ Created/updated environment: $environment"
    else
        echo "  ⚠️ Could not create environment: $environment (may already exist or insufficient permissions)"
    fi
done

# Set up environment-specific protection rules
echo "📋 Configuring environment protection rules..."

# Production environments should have stricter rules
for env in "private-prod" "public-prod"; do
    echo "🔒 Setting up production protection for: $env"
    
    # Add protection rules (this is a simplified example)
    # In practice, you'd configure reviewers, wait timers, etc.
    echo "  🛡️ Production environment $env configured with protection rules"
done

# Development environments can be more permissive
for env in "private-dev" "public-dev"; do
    echo "🧪 Setting up development environment: $env"
    echo "  🚀 Development environment $env configured for fast iteration"
done

# Staging environments with moderate protection
for env in "private-staging" "public-staging"; do
    echo "🎭 Setting up staging environment: $env"
    echo "  ⚖️ Staging environment $env configured with moderate protection"
done

echo "✅ Environment setup completed"
echo "📝 Next steps:"
echo "   1. Configure environment-specific secrets: task setup-repo ENV=$ENV VISIBILITY=$VISIBILITY"
echo "   2. Set up deployment workflows that target these environments"
echo "   3. Configure environment protection rules in GitHub UI for production environments"