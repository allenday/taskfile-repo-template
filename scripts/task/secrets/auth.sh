#!/bin/bash

set -euo pipefail

# Default environment variables for secret naming
NETWORK="${NETWORK:-LOCAL}"
ENVIRONMENT="${ENVIRONMENT:-DEV}"
SERVICE="${SERVICE:-GITLAB}"

# Bitwarden Secrets Manager configuration
BWS_ACCESS_TOKEN="${BWS_ACCESS_TOKEN:-}"
BWS_PROJECT_ID="${BWS_PROJECT_ID:-}"

# Required secret items for different services
REQUIRED_SECRETS=(
    "GITLAB_API_KEY"
)

echo "🔐 SECRETS AUTHENTICATION CHECK"
echo "==============================="
echo ""

# Check BWS configuration first
if [ -z "$BWS_ACCESS_TOKEN" ] || [ -z "$BWS_PROJECT_ID" ]; then
    echo "❌ BWS configuration missing - run 'task secrets:doctor' first"
    exit 1
fi

if ! command -v bws >/dev/null 2>&1; then
    echo "❌ BWS CLI not installed - run 'task secrets:doctor' first"
    exit 1
fi

echo "📋 Configuration:"
echo "   Network: $NETWORK"
echo "   Environment: $ENVIRONMENT" 
echo "   Service: $SERVICE"
echo ""

# Test BWS connectivity
echo "🌐 Testing BWS connectivity..."
if ! bws secret list "$BWS_PROJECT_ID" >/dev/null 2>&1; then
    echo "❌ Failed to connect to Bitwarden Secrets"
    echo "   Run 'task secrets:doctor' to diagnose connectivity issues"
    exit 1
fi
echo "✅ BWS connectivity confirmed"
echo ""

# Get all secrets for validation
echo "🔍 Checking required secrets..."
SECRETS_JSON=$(bws secret list "$BWS_PROJECT_ID" --output json 2>/dev/null || echo "[]")

MISSING_SECRETS=()
FOUND_SECRETS=()

for ITEM in "${REQUIRED_SECRETS[@]}"; do
    SECRET_NAME="${NETWORK}_${ENVIRONMENT}_${SERVICE}_${ITEM}"
    
    # Check if secret exists
    SECRET_EXISTS=$(echo "$SECRETS_JSON" | jq -r --arg name "$SECRET_NAME" '.[] | select(.key == $name) | .id' 2>/dev/null || echo "")
    
    if [ -n "$SECRET_EXISTS" ]; then
        echo "✅ $SECRET_NAME"
        FOUND_SECRETS+=("$SECRET_NAME")
    else
        echo "❌ $SECRET_NAME (missing)"
        MISSING_SECRETS+=("$SECRET_NAME")
    fi
done

echo ""
echo "🎯 Summary:"
echo "   Found: ${#FOUND_SECRETS[@]} secrets"
echo "   Missing: ${#MISSING_SECRETS[@]} secrets"

if [ ${#MISSING_SECRETS[@]} -gt 0 ]; then
    echo ""
    echo "📝 Missing secrets need to be created:"
    for secret in "${MISSING_SECRETS[@]}"; do
        echo "   • $secret"
        echo "     Create with: task secrets:create-secret SECRET_NAME=$secret SECRET_VALUE=<value>"
    done
    echo ""
    echo "❌ Authentication check failed - missing required secrets"
    exit 1
else
    echo ""
    echo "✅ All required secrets are present and accessible"
fi