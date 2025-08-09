#!/bin/bash

set -euo pipefail

ACTION="${1:-}"
SECRET_NAME="${2:-}"
SECRET_VALUE="${3:-}"
BWS_PROJECT_ID="${BWS_PROJECT_ID:-}"

if [ -z "$ACTION" ]; then
    echo "Usage: $0 <get|create|update|delete> <secret_name> [secret_value]"
    exit 1
fi

if [ -z "$SECRET_NAME" ]; then
    echo "❌ SECRET_NAME is required"
    exit 1
fi

# Helper function to find secret ID by name
find_secret_id() {
    local secret_name="$1"
    bws secret list "$BWS_PROJECT_ID" --output json 2>/dev/null | \
        jq -r --arg name "$secret_name" '.[] | select(.key == $name) | .id' 2>/dev/null || echo ""
}

case "$ACTION" in
    get)
        SECRET_ID=$(find_secret_id "$SECRET_NAME")
        if [ -z "$SECRET_ID" ]; then
            echo "❌ Secret '$SECRET_NAME' not found in project"
            exit 1
        fi
        bws secret get "$SECRET_ID"
        ;;
    create)
        if [ -z "$SECRET_VALUE" ]; then
            echo "❌ SECRET_VALUE is required for create action"
            exit 1
        fi
        # Check if secret already exists
        if [ -n "$(find_secret_id "$SECRET_NAME")" ]; then
            echo "❌ Secret '$SECRET_NAME' already exists. Use 'update' to modify it."
            exit 1
        fi
        bws secret create "$SECRET_NAME" "$SECRET_VALUE" "$BWS_PROJECT_ID"
        ;;
    update)
        if [ -z "$SECRET_VALUE" ]; then
            echo "❌ SECRET_VALUE is required for update action"
            exit 1
        fi
        SECRET_ID=$(find_secret_id "$SECRET_NAME")
        if [ -z "$SECRET_ID" ]; then
            echo "❌ Secret '$SECRET_NAME' not found in project"
            exit 1
        fi
        bws secret edit --value "$SECRET_VALUE" "$SECRET_ID"
        ;;
    delete)
        SECRET_ID=$(find_secret_id "$SECRET_NAME")
        if [ -z "$SECRET_ID" ]; then
            echo "❌ Secret '$SECRET_NAME' not found in project"
            exit 1
        fi
        bws secret delete "$SECRET_ID"
        ;;
    *)
        echo "❌ Invalid action: $ACTION"
        echo "Valid actions: get, create, update, delete"
        exit 1
        ;;
esac