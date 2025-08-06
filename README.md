# Repository Health Template

[![CI](https://github.com/allenday/taskfile-repo-template/workflows/CI/badge.svg)](https://github.com/allenday/taskfile-repo-template/actions/workflows/ci.yml)
[![Scorecard Supply Chain Security](https://github.com/allenday/taskfile-repo-template/workflows/Scorecard%20Supply%20Chain%20Security/badge.svg)](https://github.com/allenday/taskfile-repo-template/actions/workflows/scorecard.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/allenday/taskfile-repo-template/badge)](https://scorecard.dev/viewer/?uri=github.com/allenday/taskfile-repo-template)
[![Repository Health Check](https://github.com/allenday/taskfile-repo-template/workflows/Repository%20Health%20Check/badge.svg)](https://github.com/allenday/taskfile-repo-template/actions/workflows/health-check.yml)

A comprehensive template for repository health checking using Taskfile, act, and OSSF Scorecard.

## Quick Start

1. **Initialize the repository:**
   ```bash
   task init
   ```

2. **Install required tools:**
   ```bash
   task setup
   ```

3. **Run health check:**
   ```bash
   task doctor
   ```

## Available Tasks

Run `task --list` to see all available tasks.

### Core Tasks

- `task doctor` - Complete repository health check
- `task ci` - Run CI pipeline locally with act
- `task scorecard` - Run OSSF Scorecard security analysis
- `task report` - Generate comprehensive health report

### Environment Management

- `task deploy ENV=prod VISIBILITY=private` - Deploy to specific environment
- `task setup-repo ENV=staging VISIBILITY=public` - Bootstrap repository setup

### Tool Installation

- `task setup` - Install all required tools (act, scorecard, gh CLI)
- `task install-act` - Install nektos/act for local CI testing
- `task install-scorecard` - Install OSSF Scorecard for security analysis

## Multi-Environment Support

This template supports multi-tier deployments:

### Environment Types
- `dev` - Development environment
- `staging` - Pre-production environment  
- `prod` - Production environment

### Visibility Types
- `private` - Internal/intranet deployment
- `public` - Public/internet deployment

### Usage Examples

```bash
# Deploy to private development
task deploy ENV=dev VISIBILITY=private

# Deploy to public production
task deploy ENV=prod VISIBILITY=public

# Setup secrets for staging environment
task setup-repo ENV=staging VISIBILITY=private
```

## GitHub Integration

### Workflows Included

- `.github/workflows/ci.yml` - Main CI pipeline
- `.github/workflows/health-check.yml` - Weekly repository health check
- `.github/workflows/scorecard.yml` - OSSF Scorecard security analysis

### Repository Setup

The template will help you configure:

- **Secrets Management** - Repository and environment-specific secrets
- **Environments** - GitHub deployment environments with protection rules
- **Branch Protection** - Required status checks and PR reviews
- **Security Scanning** - OSSF Scorecard integration

## Local Development

### Testing Workflows Locally

```bash
# Test CI workflow
task ci

# Test specific workflow
task ci-workflow WORKFLOW=ci.yml

# Debug workflow issues
task ci-debug

# List available workflows
task ci-list
```

### Health Monitoring

```bash
# Run complete health check
task doctor

# Generate detailed report
task report

# Check specific components
./scripts/check-secrets.sh
./scripts/check-environments.sh
./scripts/check-branch-protection.sh
```

## Customization

### Scripts

All health check logic is in `scripts/` directory:

- `check-secrets.sh` - Validates GitHub secrets configuration
- `check-environments.sh` - Validates GitHub environments
- `check-branch-protection.sh` - Validates branch protection rules
- `check-workflows.sh` - Validates GitHub Actions workflows
- `deploy.sh` - Handles multi-environment deployments
- `setup-*.sh` - Bootstrap scripts for repository configuration

### Configuration

Edit `Taskfile.yml` to customize:

- Repository owner/name variables
- Default environment values
- Tool installation methods
- Deployment logic

## Prerequisites

- **Homebrew** (macOS) or **Go** for tool installation
- **GitHub CLI** for repository management
- **Git** repository with GitHub remote

## Troubleshooting

### Common Issues

1. **Permission denied on scripts**
   ```bash
   task init  # Re-run to fix permissions
   ```

2. **GitHub CLI not authenticated**
   ```bash
   gh auth login
   ```

3. **act workflows failing**
   ```bash
   task ci-debug  # Run with verbose output
   ```

### Getting Help

- Run `task --list` for available commands
- Check `task doctor` output for specific issues
- Review generated `repository-health-report.md`

## Integration

This template integrates with:

- **nektos/act** - Local GitHub Actions testing
- **OSSF Scorecard** - Security posture analysis  
- **GitHub CLI** - Repository management automation
- **Taskfile** - Modern task runner with named arguments

Perfect for teams wanting comprehensive repository health monitoring with local testing capabilities.