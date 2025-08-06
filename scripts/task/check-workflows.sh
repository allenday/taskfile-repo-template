#!/bin/bash
set -euo pipefail

echo "⚙️ Checking GitHub Actions workflows..."

# Check if .github/workflows directory exists
if [ ! -d ".github/workflows" ]; then
    echo "❌ No .github/workflows directory found"
    exit 1
fi

# Count workflow files
workflow_count=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
echo "📋 Found $workflow_count workflow files"

if [ "$workflow_count" -eq 0 ]; then
    echo "❌ No workflow files found"
    exit 1
fi

# List workflows
echo "📋 Workflow files:"
find .github/workflows -name "*.yml" -o -name "*.yaml" | while read -r workflow; do
    echo "  ✅ $(basename "$workflow")"
    
    # Basic YAML validation
    if command -v yq >/dev/null 2>&1; then
        if yq eval '.' "$workflow" >/dev/null 2>&1; then
            echo "    ✅ Valid YAML syntax"
        else
            echo "    ❌ Invalid YAML syntax"
        fi
    fi
done

# Check for common workflow patterns
echo "📋 Checking for recommended workflows:"

common_workflows=("ci" "test" "build" "deploy" "release")
for pattern in "${common_workflows[@]}"; do
    if find .github/workflows -name "*${pattern}*" | grep -q .; then
        pattern_title=$(echo "$pattern" | sed 's/^./\U&/')
        echo "  ✅ ${pattern_title} workflow found"
    else
        echo "  ⚠️ No ${pattern} workflow found"
    fi
done

# Check if act can list workflows
if command -v act >/dev/null 2>&1; then
    echo "📋 Act workflow validation:"
    if act --list >/dev/null 2>&1; then
        echo "  ✅ Workflows are compatible with act"
    else
        echo "  ⚠️ Some workflows may not be compatible with act"
    fi
fi

echo "✅ Workflow check completed"