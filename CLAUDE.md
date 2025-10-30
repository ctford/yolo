# Claude Code Notes

## Container Rebuild Required

When making changes to the yolo.sh script that affect the Docker image, you need to rebuild the container:

```bash
./yolo.sh --build
```

This forces a rebuild of the Docker image with the latest changes.

## Authentication

Claude Code is installed via npm during the image build process.

**Browser OAuth**: Run `claude` inside the container and authenticate via browser when prompted.

## Unrestricted Mode

For unrestricted access (bypasses all permission checks):
```bash
./claude-unrestricted.sh
```

**Warning**: Only use in secure, isolated environments like this container.