#!/bin/bash
# YOLO Container Status Line
# Displays skull emoji and container info

set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "/"')
DIR_NAME=$(basename "$CURRENT_DIR")

# Get git branch if available
BRANCH=""
if git rev-parse --git-dir &> /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "")
    if [[ -n "$BRANCH" ]]; then
        BRANCH=" [$BRANCH]"
    fi
fi

# Output status line with skull and YOLO branding
echo "💀 YOLO | $MODEL_DISPLAY | $DIR_NAME$BRANCH"
