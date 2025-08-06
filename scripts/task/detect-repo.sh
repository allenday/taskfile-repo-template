#!/bin/bash
set -euo pipefail

# detect-repo.sh - Extract repository owner and name from git remote
# Usage: source detect-repo.sh (sets REPO_OWNER and REPO_NAME variables)
# Or: ./detect-repo.sh (prints REPO_OWNER=value REPO_NAME=value)

detect_repo_info() {
    if ! command -v git &> /dev/null; then
        echo "Error: git command not found" >&2
        return 1
    fi

    if ! git rev-parse --git-dir &> /dev/null; then
        echo "Error: not in a git repository" >&2
        return 1
    fi

    # Try to get the remote URL
    local remote_url
    if ! remote_url=$(git remote get-url origin 2>/dev/null); then
        echo "Error: no origin remote found" >&2
        return 1
    fi

    # Parse different URL formats:
    # - git@github.com:owner/repo.git
    # - https://github.com/owner/repo.git  
    # - https://github.com/owner/repo
    local repo_owner repo_name

    if [[ $remote_url =~ ^git@github\.com:([^/]+)/([^.]+)(\.git)?$ ]]; then
        # SSH format: git@github.com:owner/repo.git
        repo_owner="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]}"
    elif [[ $remote_url =~ ^https://github\.com/([^/]+)/([^/.]+)(\.git)?(/.*)?$ ]]; then
        # HTTPS format: https://github.com/owner/repo.git
        repo_owner="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]}"
    else
        echo "Error: unable to parse GitHub URL format: $remote_url" >&2
        return 1
    fi

    if [[ -z "$repo_owner" || -z "$repo_name" ]]; then
        echo "Error: failed to extract owner/name from: $remote_url" >&2
        return 1
    fi

    # Export or print the variables
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        # Script is being executed directly, print the variables
        echo "REPO_OWNER=$repo_owner"
        echo "REPO_NAME=$repo_name"
        echo "REPO_URL=$remote_url"
    else
        # Script is being sourced, export the variables
        export REPO_OWNER="$repo_owner"
        export REPO_NAME="$repo_name" 
        export REPO_URL="$remote_url"
    fi
}

# Call the function
detect_repo_info "$@"