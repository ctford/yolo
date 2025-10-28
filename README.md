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
✅ **Read-Only Root Filesystem**: System files are immutable, prevents tampering
✅ **Temporary Directory Hardening**: `/tmp` and `/var/tmp` mounted with `noexec`, `nosuid` flags
✅ **Namespace Isolation**: Separate cgroup, IPC, mount, network, PID, and UTS namespaces
✅ **Git Repository Required**: Must be run from within a git repository for safety
✅ **Session Cleanup**: Container removed after exit (no persistent state)

### Container Hardening
✅ **Minimal Capabilities**: All capabilities dropped except `NET_BIND_SERVICE`
✅ **Resource Limits**: 4GB memory, 2 CPUs, 512 process limit
✅ **Restricted Sudo**: Sudo access limited to package management only (`apt`, `apt-get`, `dpkg`)
✅ **Writable User Space**: Only `/home/coder` is writable and executable (2GB tmpfs)

### Network & Development
✅ **Full Internet Access**: Download packages, access APIs, and use development tools
✅ **Pre-installed Tools**: Python 3, Node.js 20.x, git, vim, build-essential, Claude Code

### Remaining Limitations

⚠️ **Development Flexibility Trade-offs**:
- Sudo access to package management (allows installing system packages)
- Full network access (no egress filtering)
- User home directory is executable (needed for npm/pip packages)

**Philosophy**: This container provides strong **defense-in-depth security** while maintaining development usability. Multiple security layers protect both the host system and container internals. The primary boundary is Docker isolation, reinforced by read-only filesystem, dropped capabilities, and resource limits.  

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

This container now implements strong security hardening with some remaining trade-offs:

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