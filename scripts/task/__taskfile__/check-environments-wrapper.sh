#!/bin/bash

set -euo pipefail

# Generate environment list from template variables and check them
# This script is called with the expanded environment list from Taskfile.yml

envs="$*"
echo "Checking environments: $envs"
./scripts/task/__taskfile__/check-environments.sh $envs