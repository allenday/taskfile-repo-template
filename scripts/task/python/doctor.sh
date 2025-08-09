#!/bin/bash

set -euo pipefail

VENV_DIR="${VENV_DIR:-venv}"

echo "🐍 PYTHON DEVELOPMENT ENVIRONMENT HEALTH CHECK"
echo "=============================================="
echo ""

# Check if Python project exists
PYTHON_PROJECT=false
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "poetry.lock" ]; then
    PYTHON_PROJECT=true
fi

if [ "$PYTHON_PROJECT" = false ]; then
    echo "ℹ️  No Python project detected - skipping Python health checks"
    echo "   Looked for: requirements.txt, pyproject.toml, setup.py, poetry.lock"
    exit 0
fi

echo "🔍 Python Project Detected"
echo ""

# Check Python installation
echo "🐍 Python Installation:"
ISSUES=0

if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo "✅ Python: $PYTHON_VERSION"
    
    # Check Python version compatibility
    PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
    PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
    
    if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
        echo "✅ Python Version: Compatible (>= 3.8)"
    elif [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 6 ]; then
        echo "⚠️  Python Version: Older but supported (3.6-3.7)"
    else
        echo "❌ Python Version: Too old (< 3.6)"
        ISSUES=$((ISSUES + 1))
    fi
else
    echo "❌ Python: Not installed"
    echo "   Install: brew install python3"
    ISSUES=$((ISSUES + 1))
fi

if command -v pip3 >/dev/null 2>&1; then
    PIP_VERSION=$(pip3 --version | cut -d' ' -f2)
    echo "✅ Pip: $PIP_VERSION"
else
    echo "❌ Pip: Not installed"
    echo "   Install: python3 -m ensurepip --upgrade"
    ISSUES=$((ISSUES + 1))
fi

echo ""

# Check Virtual Environment
echo "🏗️  Virtual Environment:"
if [ -d "$VENV_DIR" ]; then
    echo "✅ Virtual Environment: Exists at $VENV_DIR"
    
    # Check if venv has Python
    if [ -f "$VENV_DIR/bin/python" ]; then
        VENV_PYTHON_VERSION=$("$VENV_DIR/bin/python" --version 2>&1 | cut -d' ' -f2 || echo "unknown")
        echo "✅ Virtual Env Python: $VENV_PYTHON_VERSION"
    else
        echo "❌ Virtual Environment: Corrupted (no Python executable)"
        ISSUES=$((ISSUES + 1))
    fi
    
    # Check if venv has pip
    if [ -f "$VENV_DIR/bin/pip" ]; then
        VENV_PIP_VERSION=$("$VENV_DIR/bin/pip" --version 2>&1 | cut -d' ' -f2 || echo "unknown")
        echo "✅ Virtual Env Pip: $VENV_PIP_VERSION"
    else
        echo "❌ Virtual Environment: Missing pip"
        ISSUES=$((ISSUES + 1))
    fi
else
    echo "⚠️  Virtual Environment: Not found"
    echo "   Create with: python3 -m venv $VENV_DIR"
    echo "   Or run: task python:venv"
fi

echo ""

# Check Project Files
echo "📄 Project Configuration:"
if [ -f "requirements.txt" ]; then
    REQ_COUNT=$(wc -l < requirements.txt | tr -d ' ')
    echo "✅ requirements.txt: $REQ_COUNT dependencies"
    
    # Check for common security issues
    if grep -q "==" requirements.txt; then
        echo "✅ requirements.txt: Uses pinned versions"
    else
        echo "⚠️  requirements.txt: Consider pinning versions for reproducibility"
    fi
else
    echo "⚠️  requirements.txt: Not found"
fi

if [ -f "pyproject.toml" ]; then
    echo "✅ pyproject.toml: Present (modern Python project)"
    
    # Check for common sections
    if grep -q "\[tool.pytest.ini_options\]" pyproject.toml 2>/dev/null; then
        echo "✅ pyproject.toml: Includes pytest configuration"
    fi
    
    if grep -q "\[tool.black\]" pyproject.toml 2>/dev/null; then
        echo "✅ pyproject.toml: Includes black configuration"
    fi
else
    echo "⚠️  pyproject.toml: Not found (consider modernizing)"
fi

if [ -f "setup.py" ]; then
    echo "✅ setup.py: Present (legacy project structure)"
fi

if [ -f "poetry.lock" ]; then
    echo "✅ poetry.lock: Present (Poetry project)"
fi

echo ""

# Check Development Tools
echo "🛠️  Development Tools:"
DEV_TOOLS=0

if [ -d "$VENV_DIR" ]; then
    # Check pytest
    if [ -f "$VENV_DIR/bin/pytest" ]; then
        PYTEST_VERSION=$("$VENV_DIR/bin/pytest" --version 2>&1 | head -1 | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" || echo "unknown")
        echo "✅ Pytest: $PYTEST_VERSION"
        DEV_TOOLS=$((DEV_TOOLS + 1))
    else
        echo "⚠️  Pytest: Not installed in virtual environment"
    fi
    
    # Check black
    if [ -f "$VENV_DIR/bin/black" ]; then
        BLACK_VERSION=$("$VENV_DIR/bin/black" --version 2>&1 | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" || echo "unknown")
        echo "✅ Black: $BLACK_VERSION"
        DEV_TOOLS=$((DEV_TOOLS + 1))
    else
        echo "⚠️  Black: Not installed in virtual environment"
    fi
    
    # Check isort
    if [ -f "$VENV_DIR/bin/isort" ]; then
        ISORT_VERSION=$("$VENV_DIR/bin/isort" --version 2>&1 | head -1 | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" || echo "unknown")
        echo "✅ Isort: $ISORT_VERSION"
        DEV_TOOLS=$((DEV_TOOLS + 1))
    else
        echo "⚠️  Isort: Not installed in virtual environment"
    fi
    
    # Check flake8
    if [ -f "$VENV_DIR/bin/flake8" ]; then
        FLAKE8_VERSION=$("$VENV_DIR/bin/flake8" --version 2>&1 | cut -d' ' -f1 || echo "unknown")
        echo "✅ Flake8: $FLAKE8_VERSION"
        DEV_TOOLS=$((DEV_TOOLS + 1))
    else
        echo "⚠️  Flake8: Not installed in virtual environment"
    fi
    
    # Check mypy
    if [ -f "$VENV_DIR/bin/mypy" ]; then
        MYPY_VERSION=$("$VENV_DIR/bin/mypy" --version 2>&1 | cut -d' ' -f2 || echo "unknown")
        echo "✅ MyPy: $MYPY_VERSION"
        DEV_TOOLS=$((DEV_TOOLS + 1))
    else
        echo "⚠️  MyPy: Not installed in virtual environment"
    fi
    
    # Check safety
    if [ -f "$VENV_DIR/bin/safety" ]; then
        SAFETY_VERSION=$("$VENV_DIR/bin/safety" --version 2>&1 | cut -d' ' -f2 || echo "unknown")
        echo "✅ Safety: $SAFETY_VERSION"
        DEV_TOOLS=$((DEV_TOOLS + 1))
    else
        echo "⚠️  Safety: Not installed in virtual environment"
    fi
    
    echo "   Total development tools: $DEV_TOOLS/6"
    if [ $DEV_TOOLS -lt 3 ]; then
        echo "   Consider running: task python:install-dev"
    fi
else
    echo "⚠️  Cannot check development tools - no virtual environment"
fi

echo ""

# Check Test Directory
echo "🧪 Testing Setup:"
if [ -d "tests" ] || [ -d "test" ]; then
    TEST_DIR="tests"
    [ -d "test" ] && TEST_DIR="test"
    
    TEST_COUNT=$(find "$TEST_DIR" -name "test_*.py" -o -name "*_test.py" | wc -l | tr -d ' ')
    echo "✅ Test Directory: $TEST_DIR with $TEST_COUNT test files"
    
    if [ -f "$TEST_DIR/__init__.py" ]; then
        echo "✅ Test Package: Properly structured"
    else
        echo "⚠️  Test Package: Missing __init__.py (may be intentional)"
    fi
else
    echo "⚠️  Test Directory: Not found"
    echo "   Create with: mkdir tests && touch tests/__init__.py"
fi

# Check for pytest configuration
if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] || [ -f "setup.cfg" ]; then
    echo "✅ Pytest Config: Found"
else
    echo "⚠️  Pytest Config: Not found"
fi

echo ""

# Summary
echo "🎯 Summary:"
if [ $ISSUES -eq 0 ]; then
    echo "✅ Python development environment health check passed"
    if [ $DEV_TOOLS -ge 4 ]; then
        echo "   Environment is well-configured for Python development"
    else
        echo "   Consider installing more development tools for better workflow"
    fi
else
    echo "❌ $ISSUES critical issues found - see above for resolution steps"
    echo "   Fix these issues to ensure proper Python development environment"
    exit 1
fi