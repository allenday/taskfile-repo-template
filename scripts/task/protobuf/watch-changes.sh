#!/bin/bash

set -euo pipefail

PROTO_DIR="${1:-proto}"

echo "Watching $PROTO_DIR for changes..."

if command -v fswatch &> /dev/null; then
    fswatch -o "$PROTO_DIR" | while read; do task gen-all; done
elif command -v inotifywait &> /dev/null; then
    while inotifywait -r -e modify "$PROTO_DIR"; do task gen-all; done
else
    echo "Install fswatch (macOS) or inotify-tools (Linux) for watch functionality"
fi