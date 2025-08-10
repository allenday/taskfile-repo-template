#!/bin/bash

set -euo pipefail

# Bitwarden Secrets Manager configuration
BWS_ACCESS_TOKEN="${BWS_ACCESS_TOKEN:-}"
BWS_PROJECT_ID="${BWS_PROJECT_ID:-}"

echo "🔐 BITWARDEN SECRETS MANAGER HEALTH CHECK"
echo "=========================================="
echo ""

# Check environment variables
echo "📋 Environment Variables:"
if [ -n "$BWS_ACCESS_TOKEN" ]; then
  echo "✅ BWS_ACCESS_TOKEN: $(echo "$BWS_ACCESS_TOKEN" | head -c 8)..."
else
  echo "❌ BWS_ACCESS_TOKEN: Not set"
fi

if [ -n "$BWS_PROJECT_ID" ]; then
  echo "✅ BWS_PROJECT_ID: $BWS_PROJECT_ID"
else
  echo "❌ BWS_PROJECT_ID: Not set"
fi
echo ""

# Check CLI installation
echo "🔧 CLI Tools:"
if command -v bws >/dev/null 2>&1; then
  BWS_VERSION=$(bws --version 2>/dev/null | head -1 || echo "unknown")
  echo "✅ Bitwarden Secrets CLI: $BWS_VERSION"
else
  echo "❌ Bitwarden Secrets CLI: Not installed"
  echo "   Install from: https://bitwarden.com/help/secrets-manager-cli/"
fi
echo ""

# Test connectivity if properly configured
PERMISSION_ISSUES=0
if [ -n "$BWS_ACCESS_TOKEN" ] && [ -n "$BWS_PROJECT_ID" ] && command -v bws >/dev/null 2>&1; then
  echo "🌐 Connectivity Test:"
  if bws secret list "$BWS_PROJECT_ID" >/dev/null 2>&1; then
    SECRET_COUNT=$(bws secret list "$BWS_PROJECT_ID" --output json 2>/dev/null | jq '. | length' 2>/dev/null || echo "unknown")
    echo "✅ Successfully connected to Bitwarden Secrets"
    echo "   Project contains $SECRET_COUNT secrets"
    
    # Check for GitLab-related secrets
    echo ""
    echo "🔍 GitLab Integration Secrets:"
    GITLAB_SECRETS=$(bws secret list "$BWS_PROJECT_ID" --output json 2>/dev/null | jq -r '.[].key' 2>/dev/null | grep -i gitlab || echo "")
    if [ -n "$GITLAB_SECRETS" ]; then
      echo "$GITLAB_SECRETS" | while read -r secret; do
        echo "✅ Found: $secret"
      done
    else
      echo "📝 No GitLab secrets found (will be created on first run)"
    fi
    
    # Test write permissions by creating and deleting a temporary secret
    echo ""
    echo "🔐 Permission Test:"
    TEST_SECRET_NAME="BWS_DOCTOR_TEST_$(date +%s)"
    
    if bws secret create "$TEST_SECRET_NAME" "test_value" "$BWS_PROJECT_ID" >/dev/null 2>&1; then
      echo "✅ Write permissions confirmed"
      # Get the secret ID to delete it
      TEST_SECRET_ID=$(bws secret list "$BWS_PROJECT_ID" --output json 2>/dev/null | jq -r --arg name "$TEST_SECRET_NAME" '.[] | select(.key == $name) | .id' 2>/dev/null)
      if [ -n "$TEST_SECRET_ID" ]; then
        if bws secret delete "$TEST_SECRET_ID" >/dev/null 2>&1; then
          echo "✅ Delete permissions confirmed"
        else
          echo "⚠️  Delete permissions limited (test secret remains: $TEST_SECRET_NAME)"
        fi
      fi
    else
      echo "⚠️  Read-only access detected"
      echo "   This access token can read secrets but cannot create/modify them"
      echo "   Secret management commands will be limited to read operations"
    fi
  else
    echo "❌ Failed to connect to Bitwarden Secrets"
    echo "   Check your BWS_ACCESS_TOKEN and BWS_PROJECT_ID"
    PERMISSION_ISSUES=1
  fi
else
  echo "⚠️  Skipping connectivity test - missing configuration"
  PERMISSION_ISSUES=0
fi

echo ""
echo "🎯 Summary:"
ISSUES=0
if [ -z "$BWS_ACCESS_TOKEN" ]; then
  echo "   • Set BWS_ACCESS_TOKEN environment variable"
  ISSUES=$((ISSUES + 1))
fi
if [ -z "$BWS_PROJECT_ID" ]; then
  echo "   • Set BWS_PROJECT_ID environment variable"  
  ISSUES=$((ISSUES + 1))
fi
if ! command -v bws >/dev/null 2>&1; then
  echo "   • Install Bitwarden Secrets CLI"
  ISSUES=$((ISSUES + 1))
fi
TOTAL_ISSUES=$((ISSUES + PERMISSION_ISSUES))
if [ $TOTAL_ISSUES -eq 0 ]; then
  echo "✅ Bitwarden Secrets Manager is properly configured with full permissions"
else
  echo "❌ $ISSUES issues found - see above for resolution steps"
  exit 1
fi