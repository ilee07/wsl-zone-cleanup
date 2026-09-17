#!/bin/bash
# Watches $HOME and deletes Windows Zone.Identifier ADS artifacts as they appear
# (these get created whenever Explorer/VS Code/a browser writes a MOTW-tagged
# file into this ext4 filesystem via \\wsl.localhost\, since ext4 has no ADS).
set -euo pipefail

WATCH_DIR="$HOME"

# One-time sweep of anything already there
find "$WATCH_DIR" -name '*:Zone.Identifier' -delete 2>/dev/null || true

inotifywait -m -r -e create -e moved_to --format '%w%f' "$WATCH_DIR" 2>/dev/null |
while IFS= read -r file; do
    case "$file" in
        *:Zone.Identifier) rm -f -- "$file" ;;
    esac
done
