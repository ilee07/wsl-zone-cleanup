#!/bin/bash
# Scripted equivalent of the manual install steps in README.md.
# Expects to be run from inside the repo (or a bundle) with
# clean-zone-identifier.sh and zone-identifier-cleanup.service alongside it.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing wsl-zone-cleanup..."

sudo apt-get update -y
sudo apt-get install -y inotify-tools

mkdir -p ~/.local/bin ~/.config/systemd/user
cp "$SCRIPT_DIR/clean-zone-identifier.sh" ~/.local/bin/
chmod +x ~/.local/bin/clean-zone-identifier.sh
cp "$SCRIPT_DIR/zone-identifier-cleanup.service" ~/.config/systemd/user/

systemctl --user daemon-reload
systemctl --user enable --now zone-identifier-cleanup.service

sudo loginctl enable-linger "$USER"

echo
echo "Done. Service status:"
systemctl --user status zone-identifier-cleanup.service --no-pager || true
