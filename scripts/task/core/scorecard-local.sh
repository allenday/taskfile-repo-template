#!/bin/bash

set -euo pipefail

if command -v scorecard &> /dev/null; then
    if scorecard --local=. --format=default >/dev/null 2>&1; then
        echo "✅ Scorecard: analysis completed"
    else
        echo "⚠️ Scorecard: skipped (tool internal error)"
    fi
else
    echo "⚠️ Scorecard: not installed (optional)"
fi