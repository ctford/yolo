#!/bin/bash

set -euo pipefail

SCRIPT_NAME="yolo.sh"
CONTAINER_NAME="yolo-coding-env"
IMAGE_NAME="yolo-coding"

usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo "Create a secure container environment for yolo coding"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --build        Force rebuild the container image"
    echo "  --shell SHELL  Specify shell (default: bash)"
    echo ""
    echo "This script must be run from within a git repository."
    echo "The current directory will be mounted as /workspace in the container."
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
    wget \
    git \
    vim \
    nano \
    tmux \
    screen \
    htop \
    tree \
    jq \
    unzip \
    zip \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    zsh \
    fish \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash -u 1000 coder
RUN usermod -aG sudo coder
RUN echo 'coder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set up workspace
WORKDIR /workspace
RUN chown coder:coder /workspace

# Switch to non-root user
USER coder

# Set up basic shell environment
RUN echo 'export PS1="\[\033[01;32m\]yolo-container\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> ~/.bashrc
RUN echo 'cd /workspace' >> ~/.bashrc

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

validate_shell() {
    local shell="$1"
    local valid_shells=("bash" "sh" "zsh" "fish")
    
    for valid_shell in "${valid_shells[@]}"; do
        if [[ "$shell" == "$valid_shell" ]]; then
            return 0
        fi
    done
    
    echo "Error: Unsupported shell '$shell'"
    echo "Supported shells: ${valid_shells[*]}"
    exit 1
}

run_container() {
    local shell_cmd="${1:-bash}"
    local git_root
    
    validate_shell "$shell_cmd"
    git_root=$(git rev-parse --show-toplevel)
    
    echo "Starting secure coding container..."
    echo "Git repository: $git_root"
    echo "Mounted as: /workspace"
    echo "Shell: $shell_cmd"
    echo ""
    echo "Security features:"
    echo "  ✓ Isolated from host filesystem (only git repo mounted)"
    echo "  ✓ Network access enabled"
    echo "  ✓ Non-root user inside container"
    echo "  ✓ No privileged access"
    echo ""
    
    # Remove existing container if it exists
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    
    # Run the container with security restrictions
    if ! docker run -it \
        --name "$CONTAINER_NAME" \
        --rm \
        --network bridge \
        --security-opt no-new-privileges:true \
        --cap-drop ALL \
        --cap-add NET_BIND_SERVICE \
        --read-only \
        --tmpfs /tmp:rw,noexec,nosuid,size=1g \
        --tmpfs /var/tmp:rw,noexec,nosuid,size=1g \
        --tmpfs /home/coder:rw,exec,nosuid,size=1g \
        --mount type=bind,source="$git_root",target=/workspace \
        --workdir /workspace \
        "$IMAGE_NAME" \
        "$shell_cmd"; then
        echo "Error: Failed to start container"
        exit 1
    fi
}

main() {
    local force_build=false
    local shell_cmd="bash"
    
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
            --shell)
                shell_cmd="$2"
                shift 2
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
    
    run_container "$shell_cmd"
}

main "$@"