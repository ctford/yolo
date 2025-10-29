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
    echo "  Alternatively, set ANTHROPIC_API_KEY environment variable before running."
}

check_requirements() {
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is required but not installed"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo "Error: Docker daemon is not running"
        echo "Please start Docker Desktop or the Docker daemon and try again"
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
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Create non-root user
RUN useradd -m -s /bin/bash -u 1000 coder
RUN usermod -aG sudo coder
# Restrict sudo to package management only for security
RUN echo 'coder ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt, /usr/bin/dpkg' >> /etc/sudoers

# Set up workspace
WORKDIR /workspace
RUN chown coder:coder /workspace

# Switch to non-root user
USER coder

# Set up npm global directory for non-root user
RUN mkdir -p ~/.npm-global \
    && npm config set prefix '~/.npm-global' \
    && echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc

# Install Claude Code via npm (more reliable than curl-based installation)
RUN export PATH=~/.npm-global/bin:$PATH \
    && npm install -g @anthropic-ai/claude-code

# Set up basic shell environment
RUN echo 'cd /workspace' >> ~/.bashrc

# Set up Claude Code configuration directory
RUN mkdir -p ~/.config/claude-code

CMD ["/bin/bash"]
EOF

    # Build the image
    if docker build -t "$IMAGE_NAME" "$build_dir"; then
        echo "Container image built successfully"
    else
        echo "Error: Failed to build container image"
        rm -rf "$build_dir"
        exit 1
    fi
    
    # Clean up
    rm -rf "$build_dir"
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
        --tmpfs /home/coder:rw,exec,size=2g \
        --tmpfs /run:rw,nosuid,nodev,size=128m \
        --memory="4g" \
        --memory-swap="4g" \
        --cpus="2.0" \
        --pids-limit=512 \
        --env ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}" \
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