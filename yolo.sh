#!/bin/bash

set -euo pipefail

SCRIPT_NAME="yolo.sh"
CONTAINER_NAME="yolo-coding-env"
IMAGE_NAME="yolo-coding"

usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo "Create a secure container environment for development with Claude Code"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --build        Force rebuild the container image"
    echo ""
    echo "This script must be run from within a git repository."
    echo "The git repository root will be mounted as /workspace in the container."
    echo ""
    echo "Claude Code Authentication:"
    echo "  Run 'claude' inside the container to authenticate via browser OAuth."
}

check_requirements() {
    if ! command -v docker &> /dev/null; then
        echo "Error: docker command not found"
        echo "Please install Docker, Colima, Podman, or another Docker-compatible runtime"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        echo "Error: Container runtime is not running"
        echo "Please start your container runtime (Docker Desktop, Colima, etc.) and try again"
        exit 1
    fi

    if ! git rev-parse --git-dir &> /dev/null; then
        echo "Error: This script must be run from within a git repository"
        exit 1
    fi
}

build_image() {
    echo "Building secure coding container image..."

    # Create temporary directory for build context
    local build_dir
    build_dir=$(mktemp -d)

    # Set up cleanup trap
    trap "rm -rf '$build_dir'" EXIT ERR

    # Create Dockerfile in build directory
    cat > "$build_dir/Dockerfile" << 'EOF'
FROM ubuntu:22.04

# Install essential development tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    jq \
    unzip \
    zip \
    build-essential \
    python3 \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (required for Claude Code)
# Download and install official Node.js binaries directly
RUN NODE_VERSION=20.18.1 && \
    curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz -o /tmp/node.tar.xz && \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm /tmp/node.tar.xz && \
    node --version && npm --version

# Install Claude Code globally as root (survives tmpfs mount of /home/coder)
RUN npm install -g @anthropic-ai/claude-code && \
    claude --version

# Create non-root user
RUN useradd -m -s /bin/bash -u 1000 coder
RUN usermod -aG sudo coder
# Restrict sudo to package management only for security
RUN mkdir -p /etc/sudoers.d && \
    echo 'coder ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt, /usr/bin/dpkg' > /etc/sudoers.d/coder && \
    chmod 0440 /etc/sudoers.d/coder

# Set up workspace
WORKDIR /workspace
RUN chown coder:coder /workspace

# Switch to non-root user
USER coder

# Create entrypoint script to set up home directory (needed because home is mounted as tmpfs)
USER root
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Recreate home directory setup (tmpfs overlay clears it)' >> /entrypoint.sh && \
    echo 'mkdir -p ~/.config/claude-code' >> /entrypoint.sh && \
    echo 'echo "cd /workspace" > ~/.bashrc' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Start bash shell' >> /entrypoint.sh && \
    echo 'exec /bin/bash' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

USER coder
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
EOF

    # Build the image
    if docker build -t "$IMAGE_NAME" "$build_dir"; then
        echo "Container image built successfully"
    else
        echo "Error: Failed to build container image"
        exit 1
    fi

    # Cleanup handled by trap
}

run_container() {
    local git_root
    git_root=$(git rev-parse --show-toplevel)

    echo "Starting secure coding container..."
    echo "Git repository: $git_root"
    echo "Mounted as: /workspace"
    echo ""
    
    # Remove existing container if it exists
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    
    # Run the container with security restrictions
    if ! docker run -it \
        --name "$CONTAINER_NAME" \
        --rm \
        --dns 8.8.8.8 \
        --dns 1.1.1.1 \
        --security-opt no-new-privileges:true \
        --cap-drop=ALL \
        --cap-add=NET_BIND_SERVICE \
        --read-only \
        --tmpfs /tmp:rw,noexec,nosuid,size=1g \
        --tmpfs /var/tmp:rw,noexec,nosuid,size=1g \
        --tmpfs /home/coder:rw,exec,size=2g,uid=1000,gid=1000 \
        --tmpfs /run:rw,nosuid,nodev,size=128m \
        --memory="4g" \
        --memory-swap="4g" \
        --cpus="2.0" \
        --pids-limit=512 \
        --mount type=bind,source="$git_root",target=/workspace \
        --workdir /workspace \
        "$IMAGE_NAME"; then
        echo "Error: Failed to start container"
        exit 1
    fi
}

main() {
    local force_build=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            --build)
                force_build=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    check_requirements

    # Build image if it doesn't exist or force build is requested
    if [[ "$force_build" == true ]] || ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
        build_image
    fi

    run_container
}

main "$@"