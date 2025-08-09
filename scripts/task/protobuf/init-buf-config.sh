#!/bin/bash

set -euo pipefail

GO_OUT="${1:-generated/go}"
PYTHON_OUT="${2:-generated/python}"

# Create buf.yaml if it doesn't exist
if [ ! -f buf.yaml ]; then
    cat > buf.yaml << 'EOF'
version: v1
breaking:
  use:
    - FILE
lint:
  use:
    - DEFAULT
EOF
    echo "Created buf.yaml"
fi

# Create buf.gen.yaml if it doesn't exist
if [ ! -f buf.gen.yaml ]; then
    cat > buf.gen.yaml << EOF
version: v1
plugins:
  - name: go
    out: $GO_OUT
    opt: paths=source_relative
  - name: go-grpc
    out: $GO_OUT
    opt: paths=source_relative
  - name: python
    out: $PYTHON_OUT
EOF
    echo "Created buf.gen.yaml"
fi

echo "Buf configuration files ready"