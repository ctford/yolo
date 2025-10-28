# YOLO Coding Container

A secure, isolated Docker container environment for experimental coding and AI-assisted development.

## Overview

`yolo.sh` creates a sandboxed container that's perfect for:
- Running AI coding assistants with `--dangerously-skip-permissions`
- Experimental development without risking your host system
- Isolated environments with network access but filesystem protection

## Security Features

✅ **Filesystem Isolation**: Only your git repository is mounted - no access to the rest of your system  
✅ **Network Access**: Full internet connectivity for downloading packages, accessing APIs  
✅ **Security Hardening**: Read-only filesystem, dropped capabilities, non-privileged user  
✅ **Git Repository Required**: Must be run from within a git repository for safety  

## Requirements

- Docker (Docker Desktop, Colima, or other Docker runtime)
- Git repository (the script validates you're in one)

### Docker Runtime Options

This script works with various Docker runtimes:
- **Docker Desktop**: The standard Docker installation
- **Colima**: Lightweight Docker runtime for macOS (`colima start`)
- **Other runtimes**: Any Docker-compatible runtime

## Usage

```bash
# Basic usage - starts container with bash
./yolo.sh

# Force rebuild the container image
./yolo.sh --build

# Use a different shell
./yolo.sh --shell zsh

# Show help
./yolo.sh --help
```

## What's Included

The container comes with essential development tools:
- **Languages**: Python 3, Node.js/npm
- **Editors**: vim, nano
- **Tools**: git, curl, wget, jq, tmux, screen, htop, tree
- **Build tools**: build-essential, unzip, zip

## How It Works

1. **Validation**: Checks for Docker and confirms you're in a git repository
2. **Image Building**: Creates a secure Ubuntu-based development environment
3. **Container Launch**: Runs with strict security settings:
   - Read-only root filesystem
   - Temporary writable areas in `/tmp` and `/home/coder`
   - All Linux capabilities dropped except network binding
   - No new privileges allowed

## Container Environment

- **Working Directory**: `/workspace` (your git repo)
- **User**: `coder` (non-root with sudo access)
- **Home**: `/home/coder` (temporary, not persisted)
- **Prompt**: Clearly labeled as `yolo-container`

## Safety Philosophy

This tool is designed for "responsible yolo coding" - giving AI assistants and yourself freedom to experiment while maintaining strong boundaries. Your host system remains protected while the container provides a full development environment.

Perfect for letting AI agents loose without worry!