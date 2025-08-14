#!/bin/bash
# Setup Solidity development environment

set -euo pipefail

echo "🚀 Setting up Solidity development environment..."

# Install Foundry if not present
if ! command -v forge >/dev/null 2>&1; then
    echo "📥 Installing Foundry..."
    curl -L https://foundry.paradigm.xyz | bash
    # Source the environment to get foundryup
    export PATH="$PATH:$HOME/.foundry/bin"
    foundryup
else
    echo "✅ Foundry already installed"
fi

# Create basic directory structure
echo "📁 Creating directory structure..."
mkdir -p src test script

# Create basic foundry.toml if it doesn't exist
if [[ ! -f "foundry.toml" ]]; then
    echo "⚙️  Creating basic foundry.toml..."
    cat > foundry.toml << 'EOF'
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
test = "test"
script = "script"
optimizer = true
optimizer_runs = 200
solc_version = "0.8.26"

[profile.ci]
fuzz = { runs = 10_000 }
invariant = { runs = 1_000 }

[profile.lite]
optimizer = false
EOF
fi

# Install forge-std if no dependencies exist
if [[ ! -d "lib" ]] || [[ -z "$(ls -A lib 2>/dev/null)" ]]; then
    echo "📦 Installing forge-std..."
    forge install foundry-rs/forge-std --no-commit
fi

# Create .gitignore for Solidity projects if it doesn't exist
if [[ ! -f ".gitignore" ]]; then
    echo "📝 Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Compiler files
cache/
out/

# Ignores development broadcast logs
!/broadcast
/broadcast/*/31337/
/broadcast/**/dry-run/

# Docs
docs/

# Dotenv file
.env

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
EOF
fi

echo "✅ Solidity development environment setup complete!"
echo "📚 Next steps:"
echo "   - Add your contracts to src/"
echo "   - Add your tests to test/"
echo "   - Add deployment scripts to script/"
echo "   - Run 'forge build' to compile"
echo "   - Run 'forge test' to run tests"