#!/bin/bash
set -euo pipefail

# sync-readme.sh - Sync README badges and references with actual git repository
# This script updates the README.md file to use the correct repository owner/name
# based on the git remote origin URL.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the repo detection script
source "$SCRIPT_DIR/detect-repo.sh"

if [[ -z "${REPO_OWNER:-}" || -z "${REPO_NAME:-}" ]]; then
    echo "❌ Failed to detect repository information" >&2
    exit 1
fi

echo "🔍 Detected repository: $REPO_OWNER/$REPO_NAME"

README_FILE="README.md"
if [[ ! -f "$README_FILE" ]]; then
    echo "❌ README.md not found in current directory" >&2
    exit 1
fi

# Create a backup
cp "$README_FILE" "$README_FILE.bak"
echo "📄 Created backup: $README_FILE.bak"

# Update the badges in README.md
# We need to be careful to preserve the structure and only update the URLs
update_badges() {
    local temp_file=$(mktemp)
    
    # Read the file and update badge URLs
    sed -e "s|https://github\.com/[^/]*/[^/]*/workflows/|https://github.com/$REPO_OWNER/$REPO_NAME/workflows/|g" \
        -e "s|https://github\.com/[^/]*/[^/]*/actions/workflows/|https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/|g" \
        -e "s|https://api\.scorecard\.dev/projects/github\.com/[^/]*/[^/]*/badge|https://api.scorecard.dev/projects/github.com/$REPO_OWNER/$REPO_NAME/badge|g" \
        -e "s|https://scorecard\.dev/viewer/\?uri=github\.com/[^/]*/[^/)]*|https://scorecard.dev/viewer/?uri=github.com/$REPO_OWNER/$REPO_NAME|g" \
        "$README_FILE" > "$temp_file"
    
    mv "$temp_file" "$README_FILE"
}

echo "🔄 Updating badges..."
update_badges

echo "✅ README.md updated successfully"
echo "🎯 Badge URLs now point to: $REPO_OWNER/$REPO_NAME"

# Show what changed
echo "📊 Changes made:"
if command -v git &> /dev/null && git rev-parse --git-dir &> /dev/null; then
    git diff --no-index "$README_FILE.bak" "$README_FILE" | grep -E '^[+-].*badge' || echo "  No badge changes detected"
else
    echo "  (git not available for diff)"
fi

echo "🔧 To revert changes, run: mv $README_FILE.bak $README_FILE"