#!/bin/bash

set -euo pipefail

PROTO_DIR="${1:-proto}"

echo "Validating protobuf files..."

if [ ! -d "$PROTO_DIR" ]; then
    echo "Proto directory $PROTO_DIR not found"
    exit 1
fi

find "$PROTO_DIR" -name "*.proto" -exec protoc \
    --proto_path="$PROTO_DIR" \
    --descriptor_set_out=/dev/null {} \;

echo "Protobuf validation completed"