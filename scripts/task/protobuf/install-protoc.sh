#!/bin/bash

set -euo pipefail

# Install Protocol Buffers compiler based on operating system
install_protoc() {
    local os="$1"
    
    case "$os" in
        darwin)
            if command -v brew &> /dev/null; then
                brew install protobuf
            else
                echo "Please install protobuf manually or install Homebrew"
                exit 1
            fi
            ;;
        linux)
            # Try apt-get first, then manual installation
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y protobuf-compiler
            else
                echo "Manual protobuf installation required for this Linux distribution"
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS: $os"
            exit 1
            ;;
    esac
}

# Get OS from environment or detect
OS="${1:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
install_protoc "$OS"