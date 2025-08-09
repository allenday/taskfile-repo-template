#!/bin/bash

set -euo pipefail

echo "🏥 COMPREHENSIVE REPOSITORY HEALTH CHECK"
echo "========================================"
echo ""

# Track overall health status
OVERALL_ISSUES=0

# Core health check (always run)
echo "🔧 Core Repository Health:"
if task core:doctor 2>/dev/null; then
    echo "✅ Core health check passed"
else
    echo "❌ Core health check found issues (see above)"
    OVERALL_ISSUES=$((OVERALL_ISSUES + 1))
fi
echo ""

# Container health check (run only if container environment detected)
if ./scripts/task/container/detect-environment.sh >/dev/null 2>&1; then
    echo "🐳 Container Environment Health:"
    if task container:doctor 2>/dev/null; then
        echo "✅ Container environment healthy"
    else
        echo "❌ Container environment issues detected"
        OVERALL_ISSUES=$((OVERALL_ISSUES + 1))
    fi
    echo ""
else
    echo "⏭️  Container environment not detected - skipping container checks"
    echo ""
fi

# Python health check (run only if Python project detected)
if [ -f requirements.txt ] || [ -f pyproject.toml ] || [ -f setup.py ] || [ -f poetry.lock ]; then
    echo "🐍 Python Environment Health:"
    if task python:doctor 2>/dev/null; then
        echo "✅ Python environment healthy"
    else
        echo "❌ Python environment issues detected"
        OVERALL_ISSUES=$((OVERALL_ISSUES + 1))
    fi
    echo ""
else
    echo "⏭️  Python project not detected - skipping Python checks"
    echo ""
fi

# Protobuf health check (run only if proto files detected)
if [ -d proto ] || find . -name "*.proto" | head -1 | grep -q . 2>/dev/null; then
    echo "⚡ Protocol Buffers Health:"
    if task protobuf:doctor 2>/dev/null; then
        echo "✅ Protobuf environment healthy"
    else
        echo "❌ Protobuf environment issues detected"
        OVERALL_ISSUES=$((OVERALL_ISSUES + 1))
    fi
    echo ""
else
    echo "⏭️  Protocol Buffers not detected - skipping protobuf checks"
    echo ""
fi

# Secrets health check (run only if Bitwarden Secrets configured)
if [ -n "${BWS_ACCESS_TOKEN:-}" ] && [ -n "${BWS_PROJECT_ID:-}" ] && command -v bws >/dev/null 2>&1; then
    echo "🔐 Secrets Management Health:"
    if task secrets:doctor 2>/dev/null; then
        echo "✅ Secrets management healthy"
    else
        echo "❌ Secrets management issues detected"
        OVERALL_ISSUES=$((OVERALL_ISSUES + 1))
    fi
    echo ""
else
    echo "⏭️  Bitwarden Secrets not configured - skipping secrets checks"
    echo ""
fi

# Summary
echo "🎯 HEALTH CHECK SUMMARY"
echo "======================"
if [ $OVERALL_ISSUES -eq 0 ]; then
    echo "✅ All health checks passed - repository is in good shape!"
else
    echo "❌ $OVERALL_ISSUES area(s) need attention (see details above)"
    echo "   Review and fix the issues to ensure optimal repository health"
fi