#!/bin/bash

set -euo pipefail

REPO_OWNER="${REPO_OWNER:-}"
REPO_NAME="${REPO_NAME:-}"

if [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
    echo "❌ REPO_OWNER and REPO_NAME must be set"
    exit 1
fi

echo "Checking repository $REPO_OWNER/$REPO_NAME"

if grep -q "$REPO_OWNER/$REPO_NAME" README.md 2>/dev/null; then
    echo "README badges are in sync"
else
    echo "README badges may be out of sync - run 'task sync'"
fi