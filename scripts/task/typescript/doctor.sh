#!/bin/bash
set -e

echo "🔧 Running TypeScript environment health check..."

# Check Node.js installation
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js: $NODE_VERSION"
else
    echo "❌ Node.js not installed"
    echo "   Install from: https://nodejs.org/"
    exit 1
fi

# Check npm installation
if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm: $NPM_VERSION"
else
    echo "❌ npm not found"
    exit 1
fi

# Check TypeScript installation (global or local)
if command -v npx >/dev/null 2>&1 && npx tsc --version >/dev/null 2>&1; then
    TS_VERSION=$(npx tsc --version)
    echo "✅ TypeScript: $TS_VERSION"
elif command -v tsc >/dev/null 2>&1; then
    TS_VERSION=$(tsc --version)
    echo "✅ TypeScript: $TS_VERSION"
else
    echo "⚠️  TypeScript not installed"
    echo "   Install with: npm install -g typescript"
fi

# Check package.json
if [ -f "package.json" ]; then
    echo "✅ package.json found"
else
    echo "⚠️  No package.json found"
fi

# Check tsconfig.json
if [ -f "tsconfig.json" ]; then
    echo "✅ tsconfig.json found"
else
    echo "⚠️  No tsconfig.json found"
fi

# Check TypeScript source directory
if [ -d "src/main/typescript" ] || [ -d "src" ]; then
    echo "✅ TypeScript source directory exists"
else
    echo "⚠️  No TypeScript source directory found"
fi

# Check test directory
if [ -d "src/test/typescript" ] || [ -d "test" ]; then
    echo "✅ Test directory exists"
else
    echo "⚠️  No test directory found"
fi

# Check node_modules
if [ -d "node_modules" ]; then
    echo "✅ Dependencies installed"
else
    echo "⚠️  Dependencies not installed (run: npm install)"
fi

echo "🎉 TypeScript environment health check completed!"