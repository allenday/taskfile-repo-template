#!/bin/bash
set -euo pipefail

echo "🔧 Checking required CLI tools..."

TOOLS_STATE_FILE="/tmp/task-tools-state"
rm -f "$TOOLS_STATE_FILE"

missing_tools=0
missing_list=""

# Check GitHub CLI
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    echo "✅ GitHub CLI: installed and authenticated"
    gh_status="✅ AUTHENTICATED"
  else
    echo "⚠️ GitHub CLI: installed but not authenticated"
    echo "   Run: gh auth login"
    gh_status="⚠️ NOT AUTHENTICATED"
  fi
else
  echo "❌ GitHub CLI: not installed"
  echo "   Install: https://cli.github.com/"
  missing_tools=$((missing_tools + 1))
  missing_list="$missing_list gh"
  gh_status="❌ NOT INSTALLED"
fi

# Check nektos/act
if command -v act >/dev/null 2>&1; then
  echo "✅ nektos/act: installed"
  act_status="✅ INSTALLED"
else
  echo "❌ nektos/act: not installed"
  echo "   Install: https://github.com/nektos/act#installation"
  missing_tools=$((missing_tools + 1))
  missing_list="$missing_list act"
  act_status="❌ NOT INSTALLED"
fi

# Check jq (commonly available in CI)
if command -v jq >/dev/null 2>&1; then
  echo "✅ jq: installed"
  jq_status="✅ INSTALLED"
else
  echo "⚠️ jq: not installed (recommended for JSON processing)"
  echo "   Install: https://jqlang.github.io/jq/download/"
  jq_status="⚠️ NOT INSTALLED"
fi

# Check OSSF Scorecard (optional)
if command -v scorecard >/dev/null 2>&1; then
  echo "✅ OSSF Scorecard: installed"
  scorecard_status="✅ INSTALLED"
else
  echo "⚠️ OSSF Scorecard: not installed (optional for security analysis)"
  echo "   Install: go install github.com/ossf/scorecard/v4@latest"
  scorecard_status="⚠️ NOT INSTALLED"
fi

# Check Docker (needed for act)
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    echo "✅ Docker: installed and running"
    docker_status="✅ RUNNING"
  else
    echo "⚠️ Docker: installed but not running"
    echo "   Start Docker daemon to use 'act' for local CI testing"
    docker_status="⚠️ NOT RUNNING"
  fi
else
  echo "⚠️ Docker: not installed (required for nektos/act)"
  echo "   Install: https://docs.docker.com/get-docker/"
  docker_status="⚠️ NOT INSTALLED"
fi

# Write state for other tasks
echo "MISSING_TOOLS=$missing_tools" > "$TOOLS_STATE_FILE"
echo "MISSING_TOOLS_LIST=\"$missing_list\"" >> "$TOOLS_STATE_FILE"
echo "GH_STATUS=\"$gh_status\"" >> "$TOOLS_STATE_FILE"
echo "ACT_STATUS=\"$act_status\"" >> "$TOOLS_STATE_FILE"
echo "JQ_STATUS=\"$jq_status\"" >> "$TOOLS_STATE_FILE"
echo "SCORECARD_STATUS=\"$scorecard_status\"" >> "$TOOLS_STATE_FILE"
echo "DOCKER_STATUS=\"$docker_status\"" >> "$TOOLS_STATE_FILE"

if [ $missing_tools -gt 0 ]; then
  echo "⚠️ $missing_tools required tool(s) missing: $missing_list"
  echo "   These tools are needed for full repository functionality"
  echo "   See installation links above or check project README"
else
  echo "✅ All required tools are installed"
fi

echo "✅ Tool check completed"