#!/bin/bash

set -euo pipefail

# Install buf protobuf tool based on operating system
install_buf() {
    local os="$1"
    
    case "$os" in
        darwin)
            if command -v brew &> /dev/null; then
                brew install bufbuild/buf/buf
            else
                curl -sSL "https://github.com/bufbuild/buf/releases/latest/download/buf-$(uname -s)-$(uname -m)" -o /usr/local/bin/buf
                chmod +x /usr/local/bin/buf
            fi
            ;;
        linux)
            curl -sSL "https://github.com/bufbuild/buf/releases/latest/download/buf-Linux-x86_64" -o /usr/local/bin/buf
            chmod +x /usr/local/bin/buf
            ;;
        *)
            echo "Unsupported OS: $os"
            exit 1
            ;;
    esac
}

# Get OS from environment or detect
OS="${1:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
install_buf "$OS"