# Claude Code Notes

## Container Rebuild Required

When making changes to the yolo.sh script that affect the Docker image, you need to rebuild the container:

```bash
./yolo.sh --build
```

This forces a rebuild of the Docker image with the latest changes.

## Authentication

Claude Code is installed via npm during the image build process and automatically starts in unrestricted mode when you enter the container.

**Browser OAuth**: When you run `./yolo.sh`, the container automatically starts Claude Code. On first use, authenticate via browser when prompted.

**Persistent Authentication**: Set `ANTHROPIC_AUTH_TOKEN` environment variable before running `./yolo.sh` to avoid re-authenticating on each container start.

## Unrestricted Mode

The container automatically starts Claude Code in unrestricted mode (bypasses all permission checks) when you enter it.

**Warning**: Only use in secure, isolated environments like this container.

**Note**: The `claude-unrestricted` command is automatically installed in the container - it's not part of the repository.