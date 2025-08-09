#!/bin/bash
set -euo pipefail

# Container Environment Detection Script
# Detects if this project uses containers and what type of deployment

detect_container_environment() {
    local container_detected=false
    local deployment_type="none"
    local compose_files=()
    local dockerfiles=()
    
    echo "=== Container Environment Detection ==="
    
    # Check for Docker Compose files
    if [ -f "deploy/docker-compose.yml" ]; then
        container_detected=true
        deployment_type="compose-deploy"
        compose_files+=("deploy/docker-compose.yml")
        echo "✅ Found: deploy/docker-compose.yml (deployment configuration)"
    fi
    
    if [ -f "docker-compose.yml" ]; then
        container_detected=true
        if [ "$deployment_type" = "none" ]; then
            deployment_type="compose-local"
        fi
        compose_files+=("docker-compose.yml")
        echo "✅ Found: docker-compose.yml (local development)"
    fi
    
    # Check for additional compose files
    for file in docker-compose.*.yml deploy/docker-compose.*.yml; do
        if [ -f "$file" ]; then
            container_detected=true
            compose_files+=("$file")
            echo "✅ Found: $file"
        fi
    done
    
    # Check for Dockerfiles
    if [ -f "Dockerfile" ]; then
        container_detected=true
        dockerfiles+=("Dockerfile")
        echo "✅ Found: Dockerfile"
    fi
    
    if [ -f "deploy/Dockerfile" ]; then
        container_detected=true
        dockerfiles+=("deploy/Dockerfile")
        echo "✅ Found: deploy/Dockerfile"
    fi
    
    # Check for other Docker-related files
    for file in Dockerfile.*; do
        if [ -f "$file" ]; then
            container_detected=true
            dockerfiles+=("$file")
            echo "✅ Found: $file"
        fi
    done
    
    if [ -f ".dockerignore" ]; then
        echo "✅ Found: .dockerignore"
    fi
    
    # Check for Kubernetes deployment indicators
    if [ -d "deploy/k8s" ] || [ -d "k8s" ]; then
        echo "✅ Found: Kubernetes manifests directory"
        if [ "$deployment_type" = "compose-deploy" ]; then
            deployment_type="hybrid-k8s-compose"
        else
            deployment_type="k8s"
        fi
    fi
    
    # Output results
    echo ""
    echo "=== Detection Results ==="
    echo "CONTAINER_DETECTED=$container_detected"
    echo "DEPLOYMENT_TYPE=$deployment_type"
    echo "COMPOSE_FILES=${compose_files[*]:-}"
    echo "DOCKERFILES=${dockerfiles[*]:-}"
    
    # Return appropriate exit code
    if [ "$container_detected" = true ]; then
        return 0
    else
        return 1
    fi
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    detect_container_environment
else
    # Script is being sourced - just define the function
    :
fi