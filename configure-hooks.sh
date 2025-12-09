#!/bin/bash
# Configure git hooks for the yolo project

set -euo pipefail

echo "Configuring git hooks..."

# Get the git directory
GIT_DIR=$(git rev-parse --git-dir)

if [[ ! -d "$GIT_DIR" ]]; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Set git hooks path to .githooks
git config core.hooksPath .githooks

# Make hook scripts executable
chmod +x .githooks/pre-commit
chmod +x .githooks/run-tests.sh

echo "✅ Git hooks configured successfully!"
echo ""
echo "Hooks installed:"
echo "  - pre-commit: Runs tests before each commit"
echo ""
echo "To run tests manually:"
echo "  ./.githooks/run-tests.sh"
