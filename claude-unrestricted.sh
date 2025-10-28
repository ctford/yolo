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

# Check if ANTHROPIC_API_KEY is set
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    echo "❌ ANTHROPIC_API_KEY environment variable is not set"
    echo "   Please set your API key: export ANTHROPIC_API_KEY=your_key_here"
    exit 1
fi

# Start Claude Code in unrestricted mode
exec claude \
    --dangerously-skip-permissions \
    --allow-all-tools \
    "$@"