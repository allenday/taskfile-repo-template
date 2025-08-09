#!/bin/bash

set -euo pipefail

REPO_OWNER="${REPO_OWNER:-}"
REPO_NAME="${REPO_NAME:-}"

if [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
    REPO_INFO=$(./scripts/task/__taskfile__/detect-repo.sh)
    REPO_OWNER=$(echo "$REPO_INFO" | grep REPO_OWNER | cut -d= -f2)
    REPO_NAME=$(echo "$REPO_INFO" | grep REPO_NAME | cut -d= -f2)
fi

echo "🏥 CORE REPOSITORY HEALTH CHECK"
echo "==============================="
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo ""

# Check CLI Tools
echo "🔧 CLI Tools:"
ISSUES=0

if command -v git >/dev/null 2>&1; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    echo "✅ Git: $GIT_VERSION"
else
    echo "❌ Git: Not installed"
    ISSUES=$((ISSUES + 1))
fi

if command -v gh >/dev/null 2>&1; then
    GH_VERSION=$(gh --version | head -1 | cut -d' ' -f3)
    echo "✅ GitHub CLI: $GH_VERSION"
    
    # Check GitHub authentication
    if gh auth status >/dev/null 2>&1; then
        GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
        echo "✅ GitHub Auth: Authenticated as $GH_USER"
    else
        echo "❌ GitHub Auth: Not authenticated"
        echo "   Run: gh auth login"
        ISSUES=$((ISSUES + 1))
    fi
else
    echo "❌ GitHub CLI: Not installed"
    echo "   Install: brew install gh"
    ISSUES=$((ISSUES + 1))
fi

if command -v act >/dev/null 2>&1; then
    ACT_VERSION=$(act --version | head -1 | cut -d' ' -f3)
    echo "✅ Act (GitHub Actions): $ACT_VERSION"
else
    echo "⚠️  Act (GitHub Actions): Not installed (optional)"
    echo "   Install: brew install act"
fi

if command -v ossf-scorecard >/dev/null 2>&1; then
    SCORECARD_VERSION=$(ossf-scorecard version 2>/dev/null | grep GitVersion | cut -d: -f2 | tr -d ' ' || echo "unknown")
    echo "✅ OSSF Scorecard: $SCORECARD_VERSION"
else
    echo "⚠️  OSSF Scorecard: Not installed (optional)"
    echo "   Install: go install github.com/ossf/scorecard/v4/cmd/scorecard@latest"
fi

echo ""

# Check Repository Structure
echo "📁 Repository Structure:"
if [ -f README.md ]; then
    if grep -q "$REPO_OWNER/$REPO_NAME" README.md 2>/dev/null; then
        echo "✅ README.md: Contains correct repository references"
    else
        echo "⚠️  README.md: May need repository reference updates"
        echo "   Run: task core:sync"
    fi
else
    echo "❌ README.md: Missing"
    ISSUES=$((ISSUES + 1))
fi

if [ -d .github/workflows ]; then
    WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$WORKFLOW_COUNT" -gt 0 ]; then
        echo "✅ GitHub Actions: $WORKFLOW_COUNT workflow(s) found"
    else
        echo "⚠️  GitHub Actions: Workflow directory exists but no workflows found"
    fi
else
    echo "⚠️  GitHub Actions: No .github/workflows directory"
fi

if [ -f .gitignore ]; then
    echo "✅ .gitignore: Present"
else
    echo "⚠️  .gitignore: Missing"
fi

echo ""

# Check Git Configuration
echo "🔀 Git Configuration:"
if git rev-parse --git-dir >/dev/null 2>&1; then
    echo "✅ Git Repository: Initialized"
    
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo "✅ Current Branch: $CURRENT_BRANCH"
    echo "✅ Default Branch: $DEFAULT_BRANCH"
    
    # Check if we have any commits
    if git log --oneline -n 1 >/dev/null 2>&1; then
        LAST_COMMIT=$(git log --oneline -n 1 --pretty=format:"%h %s" || echo "none")
        echo "✅ Last Commit: $LAST_COMMIT"
    else
        echo "⚠️  No commits found"
    fi
    
    # Check remote
    if git remote get-url origin >/dev/null 2>&1; then
        REMOTE_URL=$(git remote get-url origin)
        echo "✅ Remote Origin: $REMOTE_URL"
    else
        echo "❌ Remote Origin: Not configured"
        ISSUES=$((ISSUES + 1))
    fi
else
    echo "❌ Git Repository: Not initialized"
    ISSUES=$((ISSUES + 1))
fi

echo ""

# Summary
echo "🎯 Summary:"
if [ $ISSUES -eq 0 ]; then
    echo "✅ Core repository health check passed"
    echo "   Repository is properly configured and ready for development"
else
    echo "❌ $ISSUES critical issues found - see above for resolution steps"
    echo "   Fix these issues to ensure proper repository functionality"
    exit 1
fi