# 💀 YOLO Coding Container

[![Tests](https://github.com/ctford/yolo/actions/workflows/test.yml/badge.svg)](https://github.com/ctford/yolo/actions/workflows/test.yml)

> **⚠️ WARNING: Experimental Project**
> This is an experimental project under active development. Features, security configurations, and APIs may change without notice. Use at your own risk and always review the code before running.
>
> **Platform Support:** This script has only been tested on macOS. While it may work on Linux, compatibility is not guaranteed.

A secure, isolated Docker container environment for experimental coding and AI-assisted development.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [What's Included](#whats-included)
- [How It Works](#how-it-works)
- [Container Environment](#container-environment)
- [Claude Code Authentication](#claude-code-authentication)
- [GitHub Authentication](#github-authentication)
- [Hardening](#hardening)
- [Development](#development)

## Overview

`yolo` creates a sandboxed container that's perfect for:
- Running AI coding assistants with `--dangerously-skip-permissions`
- Experimental development without risking your host system
- Isolated environments with network access but filesystem protection

### When to Use YOLO vs. Official Devcontainer

**Use YOLO for:**
- Quick experimentation and prototyping
- Terminal-based workflows (no IDE required)
- Learning Claude Code's capabilities

**Use the [official devcontainer](https://docs.claude.com/en/docs/claude-code/devcontainer) for:**
- Team onboarding with consistent environments
- Production development workflows
- VS Code integration with extensions and debugging

## Requirements

- Docker (Docker Desktop, Colima, or other Docker runtime)
- Git repository (the script validates you're in one)

### Docker Runtime Options

This script works with various Docker runtimes:
- **Docker Desktop**: The standard Docker installation
- **Colima**: Lightweight Docker runtime for macOS (`colima start`)
- **Other runtimes**: Any Docker-compatible runtime

## Installation

`yolo` is a self-contained shell script. To install it so you can run it from anywhere:

```bash
# Create ~/bin if it doesn't exist
mkdir -p ~/bin

# Copy yolo to ~/bin and make it executable
cp yolo ~/bin/
chmod +x ~/bin/yolo

# Add ~/bin to your PATH (if not already there)
# For zsh (macOS default):
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For bash:
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Now you can run `yolo` from any git repository.

## Usage

`yolo` is designed to be run at the root of a git checkout of your project.

```bash
# Build the container image (first time setup)
yolo --build

# Run the container (after building)
yolo

# Build with additional packages
yolo --build --apt golang --npm typescript

# Show help
yolo --help  # or -h
```

The workflow is: build first with `yolo --build`, then run with `yolo`.

When you enter the container, you'll see the 💀 skull emoji in the status line, reminding you that you're in YOLO mode where Claude Code runs with all safety restrictions disabled.

## What's Included

The container comes with essential development tools:
- **Languages**: Node.js 20.x
- **Editor**: vim
- **Tools**: git, gh (GitHub CLI), curl, jq, unzip, zip, ripgrep
- **Build tools**: build-essential
- **AI Assistant**: Claude Code (installed via npm)

You can add additional packages (like Python, Go, etc.) using `--build --apt` or `--build --npm` flags.

## How It Works

1. **Validation**: Checks for Docker and confirms you're in a git repository
2. **Image Building**: Creates an Ubuntu-based development environment with essential tools
3. **Container Launch**: Runs with comprehensive security hardening:
   - **Filesystem**: Read-only root, writable tmpfs for `/home/coder`, `/tmp`, `/var/tmp`, `/run`
   - **Capabilities**: All dropped except `NET_BIND_SERVICE`
   - **Resources**: Limited to 4GB memory, 2 CPUs, 512 processes
   - **Privileges**: No new privileges, restricted sudo (apt only)
   - **Isolation**: Separate namespaces, only git repo mounted from host

## Container Environment

- **Working Directory**: `/workspace` (your git repo)
- **User**: `coder` (non-root with sudo access)
- **Home**: `/home/coder` (temporary, not persisted)
- **Status Line**: 💀 YOLO branding with model, directory, and git branch
- **Auto-start**: Claude Code launches automatically in unrestricted mode

## Claude Code Authentication

Claude Code is pre-installed in the container. Choose an authentication method:

### Browser OAuth (Quick Start)

Simplest method, but requires re-authentication each time you rebuild the container:

```bash
yolo
# Inside container:
claude
# Follow browser prompts to authenticate
```

**Note**: Authentication is stored in `/home/coder/.config/claude-code`, which is a temporary filesystem (tmpfs) that's cleared when the container exits.

### Auth Token (Persistent Authentication)

For persistent authentication across container rebuilds, use `ANTHROPIC_API_KEY`:

**One-time setup** - Get your token:
```bash
# Inside container after authenticating with browser OAuth:
cat ~/.config/claude-code/auth.json
# Copy the token value
```

**Add to your shell profile** (outside container):
```bash
# Add to ~/.zshrc or ~/.bashrc:
export ANTHROPIC_API_KEY="your-token-here"

# Reload:
source ~/.zshrc  # or ~/.bashrc
```

**Now the container auto-authenticates**:
```bash
yolo
# Claude Code is ready to use without browser authentication
```

Alternatively, set the token for a single session:
```bash
ANTHROPIC_API_KEY="your-token-here" yolo
```

### Unrestricted Mode

The container automatically starts Claude Code in unrestricted mode (bypasses all permission checks) when you enter it. You'll see the 💀 skull emoji in the status line as a visual reminder that safety restrictions are disabled.

**Warning**: Only use in this isolated container environment.

**Note**: The container runs `claude-unrestricted` automatically on startup. When you exit Claude Code, you'll exit the entire container.

## GitHub Authentication

To enable git push/pull operations with GitHub:

### Get a GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Classic"
3. Give it a descriptive name like "YOLO Container"
4. Select scopes: `repo` (full control of private repositories)
5. Generate and copy the token

### Set Token in Your Environment

```bash
# Add to ~/.zshrc or ~/.bashrc:
export GH_TOKEN="ghp_xxxxxxxxxxxx"

# Reload:
source ~/.zshrc
```

Now git operations will work automatically in the container:
```bash
yolo
# Inside container:
git add .
git commit -m "Your changes"
git push  # Works automatically with gh authentication
```

### Git Identity

Your git user.name and user.email are automatically passed through from your host configuration. To verify:

```bash
# On host:
git config user.name
git config user.email

# Inside container (automatically configured):
git config --global user.name   # Same as host
git config --global user.email  # Same as host
```

## Hardening

This container implements strong security hardening with some remaining trade-offs:

### Implemented Security ✅
1. ✅ **Restricted sudo**: Limited to package management only (`apt`, `apt-get`, `dpkg`)
2. ✅ **Read-only filesystem**: System files are immutable
3. ✅ **Minimal capabilities**: All dropped except `NET_BIND_SERVICE`
4. ✅ **Resource limits**: 4GB memory, 2 CPUs, 512 PIDs

### Remaining Trade-offs ⚠️
1. **Package installation**: Can still install system packages via apt (supply chain risk)
2. **Full network access**: No egress filtering or network restrictions
3. **Executable home directory**: `/home/coder` is writable and executable (needed for development)

**Security Posture**: This container now implements **defense-in-depth** with multiple security layers. Both host protection and container-internal hardening are strong. The remaining trade-offs are necessary for development usability while maintaining robust security boundaries.

## Development

### Security Review

When developing yolo itself, you can audit the container's security using the built-in security review command:

```bash
/security-review
```

This runs a comprehensive security audit and provides actionable recommendations.

**Note**: This command is only available when working within the yolo repository, as it depends on `.claude/commands/security-review.md`.