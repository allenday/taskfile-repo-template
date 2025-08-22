#!/bin/bash

set -euo pipefail

# Node.js tools (if npm is available)
if command -v npm &> /dev/null; then
    # Install gRPC tools globally for CLI usage
    npm install -g @grpc/grpc-js @grpc/proto-loader
    
    # Install TypeScript protobuf generators locally for project use
    npm install --save-dev ts-protoc-gen protoc-gen-ts
    
    echo "Node.js protobuf tools installed (global gRPC, local TypeScript generators)"
fi