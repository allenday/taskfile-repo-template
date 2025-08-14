#!/bin/bash
# Solidity environment health check script

set -euo pipefail

echo "🔧 Solidity Environment Health Check"
echo "=================================="

# Check for Foundry installation
if command -v forge >/dev/null 2>&1; then
    echo "✅ Foundry is installed: $(forge --version | head -n1)"
else
    echo "❌ Foundry is not installed"
    echo "   Install with: curl -L https://foundry.paradigm.xyz | bash && foundryup"
    exit 1
fi

# Check for Solidity project structure
if [[ -f "foundry.toml" ]]; then
    echo "✅ Foundry configuration found"
else
    echo "⚠️  No foundry.toml found"
fi

if [[ -d "src" ]]; then
    sol_files=$(find src -name "*.sol" 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ Solidity source directory exists ($sol_files contracts)"
else
    echo "⚠️  No src directory found"
fi

if [[ -d "test" ]]; then
    test_files=$(find test -name "*.sol" 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ Test directory exists ($test_files test files)"
else
    echo "⚠️  No test directory found"
fi

# Check for optional tools
if command -v solhint >/dev/null 2>&1; then
    echo "✅ Solhint is available for linting"
else
    echo "ℹ️  Solhint not installed (optional): npm install -g solhint"
fi

if command -v slither >/dev/null 2>&1; then
    echo "✅ Slither is available for security analysis"
else
    echo "ℹ️  Slither not installed (optional): pip install slither-analyzer"
fi

# Check dependencies
if [[ -d "lib" ]] && [[ -n "$(ls -A lib 2>/dev/null)" ]]; then
    dep_count=$(find lib -maxdepth 1 -type d -not -name lib | wc -l | tr -d ' ')
    echo "✅ Foundry dependencies installed ($dep_count dependencies)"
else
    echo "ℹ️  No Foundry dependencies found (run 'forge install' if needed)"
fi

# Try to compile
if [[ -d "src" ]] && [[ -n "$(find src -name "*.sol" 2>/dev/null)" ]]; then
    echo "🔨 Testing compilation..."
    if forge build >/dev/null 2>&1; then
        echo "✅ Contracts compile successfully"
    else
        echo "❌ Compilation failed"
        exit 1
    fi
fi

# Test if tests pass
if [[ -d "test" ]] && [[ -n "$(find test -name "*.sol" 2>/dev/null)" ]]; then
    echo "🧪 Testing test suite..."
    if forge test >/dev/null 2>&1; then
        echo "✅ All tests pass"
    else
        echo "⚠️  Some tests are failing"
    fi
fi

echo ""
echo "🎉 Solidity environment health check completed!"