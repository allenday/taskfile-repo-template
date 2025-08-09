#!/bin/bash

set -euo pipefail

# List configured environments - takes arrays as parameters
NETWORKS=("$@")

# Find where environments start (after "--")
env_start=-1
for i in "${!NETWORKS[@]}"; do
    if [ "${NETWORKS[$i]}" = "--" ]; then
        env_start=$((i + 1))
        break
    fi
done

if [ $env_start -eq -1 ]; then
    echo "Usage: $0 network1 network2 ... -- env1 env2 ... -- service1 service2 ..."
    exit 1
fi

# Extract environments
ENVIRONMENTS=()
for ((i=env_start; i < ${#NETWORKS[@]}; i++)); do
    if [ "${NETWORKS[$i]}" = "--" ]; then
        break
    fi
    ENVIRONMENTS+=("${NETWORKS[$i]}")
done

# Extract services
service_start=-1
for ((i=env_start; i < ${#NETWORKS[@]}; i++)); do
    if [ "${NETWORKS[$i]}" = "--" ]; then
        service_start=$((i + 1))
        break
    fi
done

SERVICES=()
if [ $service_start -ne -1 ]; then
    for ((i=service_start; i < ${#NETWORKS[@]}; i++)); do
        SERVICES+=("${NETWORKS[$i]}")
    done
fi

# Display results
echo "Configured Networks:"
for ((i=0; i < env_start - 1; i++)); do
    echo "  - ${NETWORKS[$i]}"
done

echo "Configured Environments:"
for env in "${ENVIRONMENTS[@]}"; do
    echo "  - $env"
done

echo "Configured Services:"
for service in "${SERVICES[@]}"; do
    echo "  - $service"
done

echo "All Environment Combinations:"
for ((i=0; i < env_start - 1; i++)); do
    network="${NETWORKS[$i]}"
    for env in "${ENVIRONMENTS[@]}"; do
        echo "  - $network-$env"
    done
done