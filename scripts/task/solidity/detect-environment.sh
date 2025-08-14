#!/bin/bash
# Detect if this is a Solidity project

set -euo pipefail

# Function to check if this is a Solidity project
is_solidity_project() {
    # Check for foundry.toml
    [[ -f "foundry.toml" ]] && return 0
    
    # Check for Solidity files in src/
    [[ -d "src" ]] && [[ -n "$(find src -name "*.sol" 2>/dev/null)" ]] && return 0
    
    # Check for Solidity files in contracts/
    [[ -d "contracts" ]] && [[ -n "$(find contracts -name "*.sol" 2>/dev/null)" ]] && return 0
    
    # Check for hardhat config
    [[ -f "hardhat.config.js" ]] || [[ -f "hardhat.config.ts" ]] && return 0
    
    # Check for truffle config
    [[ -f "truffle-config.js" ]] || [[ -f "truffle.js" ]] && return 0
    
    return 1
}

# Output detection result
if is_solidity_project; then
    echo "SOLIDITY_DETECTED=true"
    echo "SOLIDITY_TYPE=foundry"  # Could be extended to detect hardhat, truffle, etc.
else
    echo "SOLIDITY_DETECTED=false"
fi