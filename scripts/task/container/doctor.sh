#!/bin/bash
set -euo pipefail

# Container Doctor Script
# Comprehensive health check for container environments

source "$(dirname "$0")/detect-environment.sh"

container_doctor() {
    echo "🔍 CONTAINER ENVIRONMENT HEALTH CHECK"
    echo "====================================="
    
    # Detect container environment
    if ! detect_container_environment; then
        echo "ℹ️ No container environment detected - skipping container checks"
        return 0
    fi
    
    echo ""
    echo "🛠️ Checking Container Tools..."
    
    # Check Docker
    if command -v docker &> /dev/null; then
        if docker info &> /dev/null 2>&1; then
            local docker_version=$(docker --version | cut -d' ' -f3 | sed 's/,//')
            echo "✅ Docker: $docker_version (running)"
        else
            echo "⚠️ Docker: installed but not running"
            echo "   Please start Docker Desktop or Docker daemon"
            return 1
        fi
    else
        echo "❌ Docker: not installed"
        echo "   Install: brew install --cask docker"
        return 1
    fi
    
    # Check Docker Compose (modern and legacy)
    if docker compose version &> /dev/null; then
        local compose_version=$(docker compose version --short 2>/dev/null || docker compose version | head -1 | awk '{print $4}' | sed 's/v//')
        echo "✅ Docker Compose: $compose_version (built-in)"
    elif command -v docker-compose &> /dev/null; then
        local compose_version=$(docker-compose --version | cut -d' ' -f3 | sed 's/,//')
        echo "✅ Docker Compose: $compose_version (standalone)"
    else
        echo "⚠️ Docker Compose: not available"
        echo "   Docker Compose should be included with Docker Desktop"
    fi
    
    # Check specific deployment files
    echo ""
    echo "📋 Checking Deployment Configuration..."
    
    if [ -f "deploy/docker-compose.yml" ]; then
        echo "✅ deploy/docker-compose.yml exists"
        
        # Validate compose file syntax (try modern then legacy)
        if docker compose -f deploy/docker-compose.yml config &> /dev/null; then
            echo "✅ deploy/docker-compose.yml syntax is valid"
        elif command -v docker-compose &> /dev/null && docker-compose -f deploy/docker-compose.yml config &> /dev/null; then
            echo "✅ deploy/docker-compose.yml syntax is valid"
        else
            echo "❌ deploy/docker-compose.yml has syntax errors"
            echo "   Run: docker compose -f deploy/docker-compose.yml config"
            return 1
        fi
        
        # Check for required services (GitLab specific)
        if grep -q "gitlab" deploy/docker-compose.yml; then
            echo "✅ GitLab service found in compose file"
        else
            echo "⚠️ No GitLab service found in compose file"
        fi
        
        # Check for common dependencies
        if grep -q "postgresql\|postgres" deploy/docker-compose.yml; then
            echo "✅ PostgreSQL database service found"
        else
            echo "⚠️ No PostgreSQL service found - GitLab requires a database"
        fi
        
        if grep -q "redis" deploy/docker-compose.yml; then
            echo "✅ Redis cache service found"
        else
            echo "⚠️ No Redis service found - GitLab requires Redis for caching"
        fi
    fi
    
    # Check for Dockerfile
    if [ -f "deploy/Dockerfile" ]; then
        echo "✅ deploy/Dockerfile exists"
        
        # Basic Dockerfile validation
        if grep -q "FROM" deploy/Dockerfile; then
            echo "✅ Dockerfile has base image"
        else
            echo "❌ Dockerfile missing FROM instruction"
            return 1
        fi
    elif [ -f "Dockerfile" ]; then
        echo "✅ Dockerfile exists in root"
    fi
    
    # Check network connectivity (for registry access)
    echo ""
    echo "🌐 Checking Network Connectivity..."
    
    if docker pull hello-world &> /dev/null; then
        echo "✅ Docker registry connectivity working"
        docker rmi hello-world &> /dev/null || true
    else
        echo "⚠️ Docker registry connectivity issues"
        echo "   Check network connection and proxy settings"
    fi
    
    # Check available disk space
    echo ""
    echo "💾 Checking System Resources..."
    
    local available_space=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
    if [ "$available_space" -gt 10 ]; then
        echo "✅ Available disk space: ${available_space}GB"
    else
        echo "⚠️ Low disk space: ${available_space}GB available"
        echo "   Docker images require significant space"
    fi
    
    # Check for common environment files
    echo ""
    echo "⚙️ Checking Environment Configuration..."
    
    for env_file in .env .env.local .env.dev deploy/.env; do
        if [ -f "$env_file" ]; then
            echo "✅ Found: $env_file"
        fi
    done
    
    echo ""
    echo "✅ Container environment health check completed successfully!"
    return 0
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    container_doctor
fi