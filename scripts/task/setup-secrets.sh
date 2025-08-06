#!/bin/bash
set -euo pipefail

ENV=${1:-"dev"}
VISIBILITY=${2:-"private"}

echo "🔑 Setting up secrets for $VISIBILITY-$ENV environment..."

if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI not installed. Please install with: brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI. Run: gh auth login"
    exit 1
fi

# Environment-specific secrets
ENVIRONMENT="$VISIBILITY-$ENV"

echo "📋 Setting up secrets for environment: $ENVIRONMENT"

# Example secrets - replace with your actual secrets
secrets_to_setup=(
    "DATABASE_URL"
    "API_KEY"
    "JWT_SECRET"
    "REDIS_URL"
)

for secret in "${secrets_to_setup[@]}"; do
    secret_name="${secret}_${ENV^^}"
    
    # Check if secret already exists
    if gh secret list --env "$ENVIRONMENT" 2>/dev/null | grep -q "$secret_name"; then
        echo "  ⚠️ Secret $secret_name already exists for $ENVIRONMENT"
        read -p "  🔄 Update $secret_name? (y/N): " update
        if [[ $update =~ ^[Yy]$ ]]; then
            echo "  📝 Enter value for $secret_name:"
            read -s secret_value
            echo "$secret_value" | gh secret set "$secret_name" --env "$ENVIRONMENT"
            echo "  ✅ Updated $secret_name for $ENVIRONMENT"
        else
            echo "  ⏭️ Skipping $secret_name"
        fi
    else
        echo "  📝 Enter value for $secret_name (or press Enter to skip):"
        read -s secret_value
        if [ -n "$secret_value" ]; then
            echo "$secret_value" | gh secret set "$secret_name" --env "$ENVIRONMENT"
            echo "  ✅ Set $secret_name for $ENVIRONMENT"
        else
            echo "  ⏭️ Skipped $secret_name"
        fi
    fi
done

# Repository-level secrets (not environment-specific)
repo_secrets=(
    "DOCKER_REGISTRY_TOKEN"
    "SLACK_WEBHOOK_URL"
)

echo "📋 Setting up repository-level secrets..."
for secret in "${repo_secrets[@]}"; do
    if gh secret list 2>/dev/null | grep -q "$secret"; then
        echo "  ⚠️ Repository secret $secret already exists"
    else
        echo "  📝 Enter value for repository secret $secret (or press Enter to skip):"
        read -s secret_value
        if [ -n "$secret_value" ]; then
            echo "$secret_value" | gh secret set "$secret"
            echo "  ✅ Set repository secret $secret"
        else
            echo "  ⏭️ Skipped $secret"
        fi
    fi
done

echo "✅ Secret setup completed for $ENVIRONMENT"