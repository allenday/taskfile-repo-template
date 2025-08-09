#!/bin/bash

set -euo pipefail

echo "Installing gRPC tools..."

# Go tools
if command -v go &> /dev/null; then
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi