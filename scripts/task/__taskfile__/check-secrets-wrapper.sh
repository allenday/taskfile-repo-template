#!/bin/bash

set -euo pipefail

# Generate environment list from template variables and check secrets
# This script is called with the expanded environment list from Taskfile.yml

envs="$*"
echo "Checking secrets for environments: $envs"
./scripts/task/__taskfile__/check-secrets.sh $envs