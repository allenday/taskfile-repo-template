#!/bin/bash

set -euo pipefail

task container:setup 2>/dev/null || echo "Container setup not available"