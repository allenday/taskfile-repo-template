#!/bin/bash

set -euo pipefail

# Python tools (if Python is available)
if command -v pip &> /dev/null; then
    pip install grpcio-tools
fi