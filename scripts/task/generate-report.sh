#!/bin/bash
set -euo pipefail

echo "📊 Generating repository health report..."

REPORT_FILE="repository-health-report.md"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Start the report
cat > "$REPORT_FILE" << EOF
# Repository Health Report

Generated: $TIMESTAMP

## Summary

This report provides an overview of the repository's health, security posture, and compliance with best practices.

EOF

# Repository Information
echo "📋 Gathering repository information..."
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    repo_info=$(gh api repos/:owner/:repo 2>/dev/null || echo "{}")
    repo_name=$(echo "$repo_info" | jq -r '.full_name // "Unknown"')
    repo_description=$(echo "$repo_info" | jq -r '.description // "No description"')
    repo_language=$(echo "$repo_info" | jq -r '.language // "Unknown"')
    repo_stars=$(echo "$repo_info" | jq -r '.stargazers_count // 0')
    
    cat >> "$REPORT_FILE" << EOF
## Repository Information

- **Repository**: $repo_name
- **Description**: $repo_description
- **Primary Language**: $repo_language
- **Stars**: $repo_stars

EOF
fi

# Security Analysis
echo "🔐 Running security analysis..."
cat >> "$REPORT_FILE" << EOF
## Security Analysis

EOF

if command -v scorecard >/dev/null 2>&1; then
    echo "Running OSSF Scorecard analysis..."
    if scorecard --local=. --format=json > scorecard-results.json 2>/dev/null; then
        score=$(jq -r '.score' scorecard-results.json 2>/dev/null || echo "N/A")
        cat >> "$REPORT_FILE" << EOF
### OSSF Scorecard Results

- **Overall Score**: $score/10

#### Individual Checks:
EOF
        if [ -f "scorecard-results.json" ]; then
            jq -r '.checks[] | "- **\(.name)**: \(.score)/10 - \(.reason)"' scorecard-results.json >> "$REPORT_FILE" 2>/dev/null || true
        fi
    else
        echo "- ⚠️ OSSF Scorecard analysis failed or not applicable for local repository" >> "$REPORT_FILE"
    fi
else
    echo "- ⚠️ OSSF Scorecard not installed" >> "$REPORT_FILE"
fi

# GitHub Configuration
echo "🔧 Checking GitHub configuration..."
cat >> "$REPORT_FILE" << EOF

## GitHub Configuration

### Branch Protection
EOF

./scripts/check-branch-protection.sh > /tmp/branch-protection.log 2>&1
if grep -q "✅" /tmp/branch-protection.log; then
    echo "- ✅ Branch protection is configured" >> "$REPORT_FILE"
else
    echo "- ❌ Branch protection needs configuration" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

### Environments
EOF

./scripts/check-environments.sh > /tmp/environments.log 2>&1
env_count=$(grep -c "✅ Environment:" /tmp/environments.log 2>/dev/null || echo "0")
echo "- **Configured Environments**: $env_count" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << EOF

### Secrets Management
EOF

./scripts/check-secrets.sh > /tmp/secrets.log 2>&1
if grep -q "✅ Repository secrets accessible" /tmp/secrets.log; then
    secret_count=$(grep -c "✅ Environment.*secrets accessible" /tmp/secrets.log 2>/dev/null || echo "0")
    echo "- ✅ Repository secrets are configured" >> "$REPORT_FILE"
    echo "- **Environment secrets configured**: $secret_count environments" >> "$REPORT_FILE"
else
    echo "- ⚠️ Secrets configuration needs review" >> "$REPORT_FILE"
fi

# Workflow Analysis
echo "⚙️ Analyzing workflows..."
cat >> "$REPORT_FILE" << EOF

## CI/CD Workflows

EOF

./scripts/check-workflows.sh > /tmp/workflows.log 2>&1
workflow_count=$(grep -c "✅.*\.yml" /tmp/workflows.log 2>/dev/null || echo "0")
echo "- **Total Workflows**: $workflow_count" >> "$REPORT_FILE"

# Add workflow compatibility
if command -v act >/dev/null 2>&1; then
    if act --list >/dev/null 2>&1; then
        echo "- ✅ Workflows are compatible with local testing (act)" >> "$REPORT_FILE"
    else
        echo "- ⚠️ Some workflows may not be compatible with local testing" >> "$REPORT_FILE"
    fi
fi

# Recommendations
cat >> "$REPORT_FILE" << EOF

## Recommendations

Based on the analysis above, here are recommendations to improve repository health:

### Security
- Review OSSF Scorecard recommendations and address low-scoring checks
- Ensure all secrets are properly configured and rotated regularly
- Enable dependency scanning and security alerts

### CI/CD
- Ensure all critical workflows have required status checks
- Test workflows locally using \`act\` before pushing
- Consider adding automated security scanning to CI pipeline

### Repository Management  
- Configure branch protection rules for all important branches
- Set up appropriate environments for different deployment stages
- Document deployment processes and environment configurations

### Next Steps
1. Address any failing checks in this report
2. Set up regular automated security scanning
3. Review and update branch protection rules quarterly
4. Ensure all team members have appropriate access levels

---

*Report generated using repository health automation tools*
*For updates, run: \`task report\`*
EOF

echo "✅ Repository health report generated: $REPORT_FILE"
echo "📄 View the report with: cat $REPORT_FILE"

# Clean up temporary files
rm -f /tmp/branch-protection.log /tmp/environments.log /tmp/secrets.log /tmp/workflows.log scorecard-results.json 2>/dev/null || true