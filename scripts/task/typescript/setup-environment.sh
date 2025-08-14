#!/bin/bash
set -e

echo "🚀 Setting up TypeScript development environment..."

# Check if Node.js is installed
if ! command -v node >/dev/null 2>&1; then
    echo "❌ Node.js not found. Please install Node.js first:"
    echo "   Visit: https://nodejs.org/"
    exit 1
fi

# Initialize package.json if it doesn't exist
if [ ! -f "package.json" ]; then
    echo "📦 Initializing package.json..."
    npm init -y
fi

# Install TypeScript if not present
if ! npx tsc --version >/dev/null 2>&1; then
    echo "📦 Installing TypeScript..."
    npm install --save-dev typescript @types/node
fi

# Create tsconfig.json if it doesn't exist
if [ ! -f "tsconfig.json" ]; then
    echo "⚙️  Creating tsconfig.json..."
    npx tsc --init --target ES2020 --module commonjs --strict --esModuleInterop --skipLibCheck --forceConsistentCasingInFileNames
fi

# Create directory structure
echo "📁 Creating TypeScript directory structure..."
mkdir -p src/main/typescript
mkdir -p src/test/typescript

# Create basic TypeScript files if they don't exist
if [ ! -f "src/main/typescript/index.ts" ]; then
    echo "📝 Creating basic TypeScript files..."
    cat > src/main/typescript/index.ts << 'EOF'
export function main(): void {
    console.log("Hello from TypeScript!");
}

if (require.main === module) {
    main();
}
EOF
fi

if [ ! -f "src/test/typescript/index.test.ts" ]; then
    cat > src/test/typescript/index.test.ts << 'EOF'
import { main } from '../../../main/typescript/index';

describe('main function', () => {
    it('should not throw', () => {
        expect(() => main()).not.toThrow();
    });
});
EOF
fi

# Install development dependencies
echo "📦 Installing development dependencies..."
npm install --save-dev \
    jest @types/jest ts-jest \
    eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin \
    prettier

# Create Jest configuration
if [ ! -f "jest.config.js" ]; then
    echo "⚙️  Creating Jest configuration..."
    cat > jest.config.js << 'EOF'
module.exports = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    testMatch: ['**/src/test/**/*.test.ts'],
    collectCoverageFrom: [
        'src/main/**/*.ts',
        '!src/main/**/*.d.ts',
    ],
};
EOF
fi

# Create ESLint configuration
if [ ! -f ".eslintrc.js" ]; then
    echo "⚙️  Creating ESLint configuration..."
    cat > .eslintrc.js << 'EOF'
module.exports = {
    parser: '@typescript-eslint/parser',
    plugins: ['@typescript-eslint'],
    extends: [
        'eslint:recommended',
        '@typescript-eslint/recommended',
    ],
    env: {
        node: true,
        es2020: true,
    },
    parserOptions: {
        ecmaVersion: 2020,
        sourceType: 'module',
    },
};
EOF
fi

# Create Prettier configuration
if [ ! -f ".prettierrc" ]; then
    echo "⚙️  Creating Prettier configuration..."
    cat > .prettierrc << 'EOF'
{
    "semi": true,
    "trailingComma": "es5",
    "singleQuote": true,
    "printWidth": 80,
    "tabWidth": 2
}
EOF
fi

# Update package.json scripts
echo "⚙️  Updating package.json scripts..."
npm pkg set scripts.build="tsc"
npm pkg set scripts.test="jest"
npm pkg set scripts.test:watch="jest --watch"
npm pkg set scripts.test:coverage="jest --coverage"
npm pkg set scripts.lint="eslint src --ext .ts"
npm pkg set scripts.lint:fix="eslint src --ext .ts --fix"
npm pkg set scripts.format="prettier --write 'src/**/*.ts'"
npm pkg set scripts.format:check="prettier --check 'src/**/*.ts'"

echo "✅ TypeScript development environment setup complete!"
echo ""
echo "Next steps:"
echo "  - Run 'npm test' to run tests"
echo "  - Run 'npm run build' to compile TypeScript"
echo "  - Run 'npm run lint' to check code style"
echo "  - Edit src/main/typescript/index.ts to start coding"