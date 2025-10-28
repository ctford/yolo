# Claude Code Notes

## Container Rebuild Required

When making changes to the yolo.sh script that affect the Docker image (especially Claude Code installation), you need to rebuild the container:

```bash
./yolo.sh --build
```

This forces a rebuild of the Docker image with the latest changes.

## Known Issues

- Claude Code installation during build may fail due to DNS resolution issues in some Docker environments
- Container may need manual Claude Code installation if automatic installation fails