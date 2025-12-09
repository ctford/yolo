#!/bin/bash
# Run all tests for the yolo project

set -e

echo "🔍 Running shellcheck on yolo.sh..."

# Check if shellcheck is installed
if ! command -v shellcheck &> /dev/null; then
    echo "⚠️  shellcheck not found. Install it with:"
    echo "   macOS: brew install shellcheck"
    echo "   Linux: apt-get install shellcheck"
    exit 1
fi

# Run shellcheck on yolo.sh
shellcheck yolo.sh

echo "✅ Shellcheck passed!"
