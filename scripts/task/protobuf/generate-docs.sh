#!/bin/bash

set -euo pipefail

PROTO_DIR="${1:-proto}"

if command -v protoc-gen-doc &> /dev/null; then
    protoc --doc_out=./docs --doc_opt=html,index.html --proto_path="$PROTO_DIR" "$PROTO_DIR"/*.proto
else
    echo "Install protoc-gen-doc for documentation generation"
    echo "https://github.com/pseudomuto/protoc-gen-doc"
fi