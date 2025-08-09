#!/bin/bash

set -euo pipefail

# Node.js tools (if npm is available)
if command -v npm &> /dev/null; then
    npm install -g @grpc/grpc-js @grpc/proto-loader
    npm install -g ts-protoc-gen protoc-gen-ts
fi