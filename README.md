# Repository Health Template

[![CI](https://github.com/allenday/taskfile-repo-template/workflows/CI/badge.svg)](https://github.com/allenday/taskfile-repo-template/actions/workflows/ci.yml)
[![Scorecard Supply Chain Security](https://github.com/allenday/taskfile-repo-template/workflows/Scorecard%20Supply%20Chain%20Security/badge.svg)](https://github.com/allenday/taskfile-repo-template/actions/workflows/scorecard.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/allenday/taskfile-repo-template/badge)](https://scorecard.dev/viewer/?uri=github.com/allenday/taskfile-repo-template)
[![Repository Health Check](https://github.com/allenday/taskfile-repo-template/workflows/Repository%20Health%20Check/badge.svg)](https://github.com/allenday/taskfile-repo-template/actions/workflows/health-check.yml)

A comprehensive template for repository health checking using Taskfile, act, and OSSF Scorecard.

## Integration into Your Project

To integrate this template into your existing project, follow these steps:

### 1. Add as Git Submodule

```bash
# Create third_party directory for external dependencies
mkdir -p third_party

# Add the template as a git submodule
git submodule add git@github.com:allenday/taskfile-repo-template.git third_party/taskfile-repo-template
```

### 2. Create Project Structure

```bash
# Create required directories
mkdir -p taskfiles scripts/task

# Create your main Taskfile.yml (includes template modules)
cat > Taskfile.yml << 'EOF'
version: '3'

includes:
  # Core repository health and CI tasks (always included)
  core:
    taskfile: ./taskfiles/Core.yml
    dir: .
  
  # Optional technology-specific extensions
  python:
    taskfile: ./taskfiles/Python.yml
    optional: true
    aliases: [py]
  
  protobuf:
    taskfile: ./taskfiles/Protobuf.yml
    optional: true
    aliases: [proto, pb]
  
  # Container orchestration (optional)
  container:
    taskfile: ./taskfiles/Container.yml
    optional: true
    aliases: [docker]
  
  # Secret management
  secrets:
    taskfile: ./taskfiles/Secrets.yml
    optional: true
    aliases: [bws]
  
  # Application-specific tasks (customize for your project)
  app:
    taskfile: ./taskfiles/App.yml
    aliases: [myapp]  # Replace with your app name

vars:
  REPO_OWNER:
    sh: ./scripts/task/detect-repo.sh | grep REPO_OWNER | cut -d= -f2
  REPO_NAME:
    sh: ./scripts/task/detect-repo.sh | grep REPO_NAME | cut -d= -f2

tasks:
  default:
    desc: List all available tasks across modules
    cmds:
      - task --list

  doctor:
    desc: Complete repository health check (core + technology-specific)
    cmds:
      - echo "🏥 COMPREHENSIVE REPOSITORY HEALTH CHECK"
      - echo "========================================"
      - echo ""
      - task core:doctor || echo "⚠️  Core health check found issues (see above)"
      - echo ""
      - task container:doctor 2>/dev/null || echo "⏭️  Container checks skipped (no container environment detected)"
      - echo ""
      - task python:doctor 2>/dev/null || echo "⏭️  Python checks skipped (no Python project detected)"
      - echo ""
      - task protobuf:doctor 2>/dev/null || echo "⏭️  Protobuf checks skipped (no protobuf project detected)"
      - echo ""
      - task secrets:doctor 2>/dev/null || echo "⏭️  Secrets checks skipped (Bitwarden Secrets not configured)"
      - echo ""
      - echo "🎉 COMPREHENSIVE HEALTH CHECK COMPLETED"
      - echo "========================================"
EOF
```

### 3. Create Symlinks to Template

```bash
# Symlink template taskfiles to your taskfiles directory
cd taskfiles
ln -sf ../third_party/taskfile-repo-template/taskfiles/Core.yml Core.yml
ln -sf ../third_party/taskfile-repo-template/taskfiles/Python.yml Python.yml
ln -sf ../third_party/taskfile-repo-template/taskfiles/Protobuf.yml Protobuf.yml
ln -sf ../third_party/taskfile-repo-template/taskfiles/Container.yml Container.yml
ln -sf ../third_party/taskfile-repo-template/taskfiles/Secrets.yml Secrets.yml

# Symlink template scripts to your scripts directory
cd ../scripts/task
ln -sf ../../third_party/taskfile-repo-template/scripts/task/check-tools.sh check-tools.sh
ln -sf ../../third_party/taskfile-repo-template/scripts/task/detect-repo.sh detect-repo.sh
ln -sf ../../third_party/taskfile-repo-template/scripts/task/core core
ln -sf ../../third_party/taskfile-repo-template/scripts/task/python python
ln -sf ../../third_party/taskfile-repo-template/scripts/task/protobuf protobuf
ln -sf ../../third_party/taskfile-repo-template/scripts/task/container container
ln -sf ../../third_party/taskfile-repo-template/scripts/task/secrets secrets

# Go back to project root
cd ../..
```

### 4. Create Application-Specific Tasks

```bash
# Create your application-specific taskfile
cat > taskfiles/App.yml << 'EOF'
version: '3'

vars:
  APP_NAME: 'myapp'  # Replace with your application name

tasks:
  setup:
    desc: Setup application environment
    cmds:
      - echo "Setting up {{.APP_NAME}}..."
      # Add your application setup commands here

  test:
    desc: Run application tests
    cmds:
      - echo "Running {{.APP_NAME}} tests..."
      # Add your test commands here

  deploy:
    desc: Deploy application
    cmds:
      - echo "Deploying {{.APP_NAME}}..."
      # Add your deployment commands here

  doctor:
    desc: Application health check
    cmds:
      - echo "🔍 {{.APP_NAME}} HEALTH CHECK"
      - echo "========================="
      # Add your application-specific health checks here
      - echo "✅ Application health check completed"
EOF
```

### 5. Create GitHub Workflows (Optional)

```bash
# Create .github/workflows directory if it doesn't exist
mkdir -p .github/workflows

# Copy template workflows (customize as needed)
cp third_party/taskfile-repo-template/.github/workflows/ci.yml .github/workflows/
cp third_party/taskfile-repo-template/.github/workflows/health-check.yml .github/workflows/

# Customize workflows for your project needs
```

### 6. Initialize and Test

```bash
# Add all changes to git
git add .

# Test the integration
task --list  # Should show all available tasks
task core:doctor  # Test core health checks
task doctor  # Run comprehensive health check

# Commit the integration
git commit -m "feat: integrate taskfile-repo-template

- Add template as git submodule
- Create modular Taskfile.yml with optional includes  
- Symlink template taskfiles and scripts
- Add application-specific App.yml taskfile
- Enable comprehensive health monitoring with task doctor"
```

## Resource Naming and Directory Organization

This template implements a **5-dimensional resource naming pattern** to organize secrets, configuration, and deployment artifacts in a consistent, scalable way.

### 5D Resource Naming Pattern

All resources follow this naming convention:
```
${CONCERN}_${NETWORK}_${ENVIRONMENT}_${COMPONENT}_${RESOURCE}
```

**Dimensions explained:**
- **CONCERN**: What domain/system the resource belongs to (`DEPLOY`, `CHAIN`, `API`)
- **NETWORK**: Where the resource is used (`LOCAL`, `CLOUD`, `INTRANET`)  
- **ENVIRONMENT**: Lifecycle stage (`DEV`, `STAGING`, `PROD`)
- **COMPONENT**: Application part (`VALIDATOR`, `DAPP`, `API`)
- **RESOURCE**: Actual config/secret (`PRIVATE_KEY`, `URL`, `TOKEN`)

**Examples:**
```bash
DEPLOY_LOCAL_DEV_VALIDATOR_PRIVATE_KEY     # Local development validator private key
DEPLOY_CLOUD_PROD_DAPP_CDN_URL            # Production dApp CDN URL  
CHAIN_BASE_SEPOLIA_STAGING_CONTRACTS_RPC_URL  # Staging blockchain RPC endpoint
API_CLOUD_PROD_GITHUB_TOKEN               # Production GitHub API token
```

### Directory Structure Alignment

Organize your directories to match the resource naming pattern:

```
src/main/
├── typescript/
│   ├── validator/          # DEPLOY_*_*_VALIDATOR_* resources
│   └── dapp/              # DEPLOY_*_*_DAPP_* resources  
└── solidity/              # CHAIN_*_*_CONTRACTS_* resources

deploy/
├── local/                 # DEPLOY_LOCAL_*_*_* configs
│   ├── dev/
│   │   ├── validator/
│   │   └── dapp/
│   ├── staging/
│   └── prod/
└── cloud/                 # DEPLOY_CLOUD_*_*_* configs
    ├── dev/
    ├── staging/  
    └── prod/
```

### Configuration in Taskfile.yml

Define your project's 5D grid in your main `Taskfile.yml`:

```yaml
vars:
  # 5-dimensional resource configuration
  # Pattern: ${CONCERN}_${NETWORK}_${ENVIRONMENT}_${COMPONENT}_${RESOURCE}
  CONCERNS:
    - deploy
    - chain
    - api
  NETWORKS:
    - local
    - cloud
  ENVIRONMENTS:
    - dev
    - staging
    - prod
  COMPONENTS:
    - validator
    - dapp
```

### Benefits

- **Intuitive navigation**: Directory structure matches resource names
- **Scalable organization**: Clear patterns that grow with project complexity  
- **Consistent tooling**: Template scripts work across all resource types
- **Clear mental model**: Developers quickly understand where things belong
- **Automation friendly**: Scripts can iterate over the full grid for validation

### Secret Resolution

The template's secret resolution follows the 5D hierarchy, trying:
1. Environment variables (highest precedence)
2. `.env` files (medium precedence)  
3. Bitwarden Secrets Manager (lowest precedence, authoritative)

Use `task secrets:resolve SECRET_ITEM=GITHUB_TOKEN` to test resolution.

## Quick Start (For Template Users)

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

## Modular Doctor System

The template includes a comprehensive health monitoring system with specialized doctor scripts for different technology domains:

### Core Health Checks

```bash
task core:doctor        # Repository, Git, CLI tools
task container:doctor   # Docker, Compose, deployments
task python:doctor      # Virtual environments, dependencies
task protobuf:doctor    # Protocol Buffers tooling, project structure
task secrets:doctor     # Bitwarden Secrets Manager integration
```

### Unified Health Check

```bash
task doctor  # Runs all applicable health checks with smart detection
```

The unified doctor automatically detects your project type and runs relevant checks:
- ✅ **Always runs**: Core repository health checks
- 🔍 **Auto-detects**: Container environments (Docker, Kubernetes)
- 🐍 **Auto-detects**: Python projects (requirements.txt, pyproject.toml)
- ⚡ **Auto-detects**: Protobuf projects (proto/ directory, *.proto files)
- 🔐 **Configurable**: Bitwarden Secrets (BWS_ACCESS_TOKEN, BWS_PROJECT_ID)

### Example Output

```bash
$ task doctor
🏥 COMPREHENSIVE REPOSITORY HEALTH CHECK
========================================

🏥 CORE REPOSITORY HEALTH CHECK
===============================
✅ Git: 2.43.0
✅ GitHub CLI: 2.74.2 
✅ GitHub Auth: Authenticated as username
⚠️  OSSF Scorecard: Not installed (optional)

🔍 CONTAINER ENVIRONMENT HEALTH CHECK
=====================================
✅ Docker: 24.0.7 (running)
✅ Docker Compose: 2.38.2 (built-in)
✅ deploy/docker-compose.yml syntax is valid

🐍 PYTHON DEVELOPMENT ENVIRONMENT HEALTH CHECK
==============================================
ℹ️  No Python project detected - skipping Python health checks

🎉 COMPREHENSIVE HEALTH CHECK COMPLETED
========================================
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

### Integration Issues

1. **Symlinks not working**
   ```bash
   # Check if symlinks are created correctly
   ls -la taskfiles/
   ls -la scripts/task/
   
   # Recreate broken symlinks
   rm -f taskfiles/Core.yml
   ln -sf ../third_party/taskfile-repo-template/taskfiles/Core.yml taskfiles/Core.yml
   ```

2. **Submodule update issues**
   ```bash
   # Update submodule to latest
   git submodule update --remote third_party/taskfile-repo-template
   
   # Initialize submodules after cloning
   git submodule update --init --recursive
   ```

3. **Task not found errors**
   ```bash
   # Verify taskfile includes are correct
   task --list
   
   # Check for missing symlinks
   task core:doctor 2>&1 | grep "No such file"
   ```

4. **Permission denied on scripts**
   ```bash
   # Fix script permissions
   chmod +x scripts/task/*/doctor.sh
   chmod +x third_party/taskfile-repo-template/scripts/task/*/doctor.sh
   ```

### Getting Help

- Run `task --list` for available commands
- Check `task doctor` output for specific issues
- Review generated `repository-health-report.md`
- Verify symlinks: `ls -la taskfiles/ scripts/task/`

## Integration

This template integrates with:

- **nektos/act** - Local GitHub Actions testing
- **OSSF Scorecard** - Security posture analysis  
- **GitHub CLI** - Repository management automation
- **Taskfile** - Modern task runner with named arguments

Perfect for teams wanting comprehensive repository health monitoring with local testing capabilities.

## Advanced Customization

### Adding Custom Doctor Scripts

Create domain-specific health checks for your technology stack:

```bash
# Create custom doctor script
mkdir -p scripts/task/mytech
cat > scripts/task/mytech/doctor.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🔍 MY TECHNOLOGY HEALTH CHECK"
echo "============================"
echo ""

# Check if project uses your technology
if [ ! -f "mytech.config" ]; then
    echo "ℹ️  No MyTech project detected - skipping checks"
    exit 0
fi

# Add your health checks here
echo "✅ MyTech configuration valid"
echo "✅ MyTech dependencies installed"

echo ""
echo "🎯 Summary: MyTech environment is healthy"
EOF

chmod +x scripts/task/mytech/doctor.sh
```

### Creating Custom Taskfiles

Extend the template with your own taskfile modules:

```bash
# Create custom taskfile
cat > taskfiles/MyTech.yml << 'EOF'
version: '3'

vars:
  MYTECH_CONFIG: mytech.config

tasks:
  doctor:
    desc: MyTech development environment health check
    cmds:
      - ./scripts/task/mytech/doctor.sh

  setup:
    desc: Setup MyTech development environment
    cmds:
      - echo "Setting up MyTech..."
      - # Add setup commands

  test:
    desc: Run MyTech tests
    cmds:
      - echo "Running MyTech tests..."
      - # Add test commands
EOF
```

Then include it in your main Taskfile.yml:

```yaml
includes:
  mytech:
    taskfile: ./taskfiles/MyTech.yml
    optional: true
    aliases: [mt]
```

### Environment-Specific Configuration

Create environment-specific configurations:

```bash
# Development environment
export BWS_ACCESS_TOKEN="your-dev-token"
export BWS_PROJECT_ID="your-dev-project-id"

# Production environment  
export BWS_ACCESS_TOKEN="your-prod-token"
export BWS_PROJECT_ID="your-prod-project-id"

# Test all environments
for env in dev staging prod; do
    echo "Testing $env environment..."
    ENV=$env task doctor
done
```

## Contributing

To contribute improvements back to the template:

1. Fork the repository
2. Create a feature branch
3. Add your improvements (new doctor scripts, taskfiles, etc.)
4. Test with multiple project types
5. Submit a pull request

The template is designed to be extensible and welcomes contributions for new technology domains!