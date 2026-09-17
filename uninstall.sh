#!/bin/bash
# Reverses install.sh: stops and removes the service, undoes linger.
set -euo pipefail

systemctl --user disable --now zone-identifier-cleanup.service 2>/dev/null || true
rm -f ~/.local/bin/clean-zone-identifier.sh
rm -f ~/.config/systemd/user/zone-identifier-cleanup.service
systemctl --user daemon-reload
systemctl --user reset-failed 2>/dev/null || true

sudo loginctl disable-linger "$USER"

echo "wsl-zone-cleanup removed."
