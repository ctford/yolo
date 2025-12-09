# Claude Code Notes

## Design Principle: Self-Contained Script

**Important**: The `yolo` script must be self-contained and not depend on other files in the repository. It should generate all necessary configuration, scripts, and tooling within the container during the build or startup process.

**Why**: This ensures the script can be easily distributed and used in any git repository without requiring additional files. Users should be able to copy just `yolo` to their project and have it work.

**Examples**:
- The `claude-unrestricted` command is generated in `/usr/local/bin/` during image build
- The YOLO statusline script and settings are generated in `~/.claude/` during container startup
- All Docker configuration is embedded in the Dockerfile heredoc within the script

## Container Rebuild Required

When making changes to the yolo script that affect the Docker image, you need to rebuild the container:

```bash
./yolo --build
```

This forces a rebuild of the Docker image with the latest changes.

## Authentication

Claude Code is installed via npm during the image build process and automatically starts in unrestricted mode when you enter the container.

**Browser OAuth**: When you run `./yolo`, the container automatically starts Claude Code. On first use, authenticate via browser when prompted.

**Persistent Authentication**: Set `ANTHROPIC_API_KEY` environment variable before running `./yolo` to avoid re-authenticating on each container start.

## Unrestricted Mode

The container automatically starts Claude Code in unrestricted mode (bypasses all permission checks) when you enter it.

**Warning**: Only use in secure, isolated environments like this container.

**Note**: The `claude-unrestricted` command is automatically installed in the container - it's not part of the repository.