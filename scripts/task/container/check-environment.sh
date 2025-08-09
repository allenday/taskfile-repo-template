#!/bin/bash

set -euo pipefail

# Check if container environment is detected and run appropriate checks
if ./scripts/task/container/detect-environment.sh >/dev/null 2>&1; then
    echo "Container environment detected - running container health checks..."
    ./scripts/task/container/doctor.sh
else
    echo "No container environment detected"
fi