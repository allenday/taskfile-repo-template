#!/bin/bash

set -euo pipefail

# Check Docker installation and status
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        echo "Docker: installed and running"
    else
        echo "Docker: installed but not running"
    fi
else
    echo "Docker: not installed"
fi