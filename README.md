# YOLO Coding Container

A secure, isolated Docker container environment for experimental coding and AI-assisted development.

## Overview

`yolo.sh` creates a sandboxed container that's perfect for:
- Running AI coding assistants with `--dangerously-skip-permissions`
- Experimental development without risking your host system
- Isolated environments with network access but filesystem protection

## Security Features

### Strong Host Protection
✅ **Filesystem Isolation**: Only your git repository is mounted - no access to the rest of your system
✅ **No New Privileges**: Prevents privilege escalation via setuid binaries
✅ **Temporary Directory Hardening**: `/tmp` and `/var/tmp` mounted with `noexec`, `nosuid` flags
✅ **Namespace Isolation**: Separate cgroup, IPC, mount, network, PID, and UTS namespaces
✅ **Git Repository Required**: Must be run from within a git repository for safety
✅ **Session Cleanup**: Container removed after exit (no persistent state)

### Network & Development
✅ **Full Internet Access**: Download packages, access APIs, and use development tools
✅ **Pre-installed Tools**: Python 3, Node.js 20.x, git, vim, build-essential, Claude Code

### Current Limitations

⚠️ **Container-Internal Security**: The container prioritizes development flexibility over internal hardening:
- User has passwordless sudo access (root-equivalent inside container)
- Writable root filesystem (not read-only as in earlier versions)
- Default Docker capabilities (not dropped for compatibility)
- No resource limits (memory, CPU, PIDs)
- Full network access (no egress filtering)

**Philosophy**: This container provides strong **host system protection** while giving you freedom to experiment inside. The primary security boundary is the Docker isolation layer. Treat the container as a sandbox where anything can happen, but your host remains safe.  

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

# Show help
./yolo.sh --help
```

## What's Included

The container comes with essential development tools:
- **Languages**: Python 3, Node.js 20.x
- **Editor**: vim
- **Tools**: git, curl, jq, unzip, zip
- **Build tools**: build-essential
- **AI Assistant**: Claude Code (installed via npm)

## How It Works

1. **Validation**: Checks for Docker and confirms you're in a git repository
2. **Image Building**: Creates an Ubuntu-based development environment with essential tools
3. **Container Launch**: Runs with security settings focused on host protection:
   - Host filesystem isolated (only git repo mounted)
   - Temporary directories (`/tmp`, `/var/tmp`) hardened with `noexec`, `nosuid`
   - No new privileges allowed (`--security-opt no-new-privileges:true`)
   - Namespace isolation for process and network separation

## Container Environment

- **Working Directory**: `/workspace` (your git repo)
- **User**: `coder` (non-root with sudo access)
- **Home**: `/home/coder` (temporary, not persisted)
- **Shell**: bash

## Claude Code Authentication

Claude Code is pre-installed in the container. To use it:

1. **Browser OAuth** (recommended): Run `claude` inside the container and authenticate via browser
2. **API Key**: Set `ANTHROPIC_API_KEY` environment variable before starting the container

For unrestricted mode (bypasses all safety checks):
```bash
./claude-unrestricted.sh
```

## Safety Philosophy

This tool is designed for "responsible yolo coding" - giving AI assistants and yourself freedom to experiment while maintaining strong boundaries. Your host system remains protected while the container provides a full development environment.

Perfect for letting AI agents loose without worry about your host system!

## Security Review

Want to audit the container's security? Use the built-in security review command:

```bash
/security-review
```

This runs a comprehensive security audit and provides actionable recommendations.

## Security Best Practices

### ✅ Safe Use Cases
- Personal experimentation and learning
- AI-assisted development with code review
- Prototyping with known dependencies
- Running code you would trust on your host

### ⚠️ Use with Caution
- Running untrusted or unknown code
- Processing sensitive data or credentials
- Installing packages from unverified sources
- Long-running or production workloads

### 🔒 Recommendations
- Review AI-generated commands before using unrestricted mode
- Use a separate API key with usage limits
- Monitor network traffic when working with unfamiliar code
- Regularly rebuild the image: `./yolo.sh --build`
- Don't commit secrets or API keys to the git repository

## Known Security Limitations

This container prioritizes ease of development over internal hardening. Key limitations:

1. **Passwordless sudo**: User has root-equivalent access inside container
2. **Writable filesystem**: Malicious code could modify system files (within session)
3. **Full network access**: No egress filtering or network restrictions
4. **Default capabilities**: Standard Docker capability set (not minimized)
5. **No resource limits**: Processes could consume all available resources

**These are acceptable tradeoffs** for a development sandbox where the primary security boundary is Docker isolation. Your host system remains protected regardless of what happens inside the container.