#!/bin/bash

# claude-unrestricted.sh - Start Claude Code with all restrictions disabled
# WARNING: This bypasses all safety mechanisms. Use only in secure environments.

set -euo pipefail

echo "⚠️  WARNING: Starting Claude Code in unrestricted mode"
echo "   This bypasses all safety mechanisms and permission checks"
echo "   Use only in secure, isolated environments"
echo ""

# Check if Claude Code is installed
if ! command -v claude >/dev/null 2>&1; then
    echo "❌ Claude Code is not installed. Please install it first:"
    echo "   npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# Start Claude Code in unrestricted mode (will use browser OAuth if not authenticated)
exec claude \
    --dangerously-skip-permissions \
    "$@"