#!/bin/bash

set -euo pipefail

WORKFLOW_COUNT="${1:-0}"

if [ "$WORKFLOW_COUNT" -gt 0 ]; then
    ./scripts/task/core/check-workflows.sh
else
    echo "No workflow files found in .github/workflows"
fi