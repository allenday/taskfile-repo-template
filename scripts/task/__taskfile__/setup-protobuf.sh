#!/bin/bash

set -euo pipefail

if [ -d proto ] || find . -name "*.proto" | head -1 | grep -q .; then
    echo "Protocol Buffers detected - setting up protobuf environment"
    task protobuf:setup-protobuf 2>/dev/null || echo "Protobuf tasks not available"
fi