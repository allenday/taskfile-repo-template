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

case "$ACTION" in
    get)
        bws secret get "$SECRET_NAME" --project-id "$BWS_PROJECT_ID"
        ;;
    create)
        if [ -z "$SECRET_VALUE" ]; then
            echo "❌ SECRET_VALUE is required for create action"
            exit 1
        fi
        bws secret create "$SECRET_NAME" "$SECRET_VALUE" --project-id "$BWS_PROJECT_ID"
        ;;
    update)
        if [ -z "$SECRET_VALUE" ]; then
            echo "❌ SECRET_VALUE is required for update action"
            exit 1
        fi
        bws secret edit "$SECRET_NAME" --value "$SECRET_VALUE" --project-id "$BWS_PROJECT_ID"
        ;;
    delete)
        bws secret delete "$SECRET_NAME" --project-id "$BWS_PROJECT_ID"
        ;;
    *)
        echo "❌ Invalid action: $ACTION"
        echo "Valid actions: get, create, update, delete"
        exit 1
        ;;
esac