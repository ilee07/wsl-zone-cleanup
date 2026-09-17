# wsl-zone-cleanup

Auto-deletes Windows `*:Zone.Identifier` artifact files from your WSL home directory.

## Why these appear

Zone.Identifier is an NTFS alternate-data-stream (ADS) Windows attaches to a file
to mark it as downloaded ("Mark of the Web"). NTFS/DrvFs (`/mnt/c`) stores this
invisibly. Your WSL home is ext4, which has no ADS support — so when a
Windows-side process (Explorer, VS Code, a browser) writes or copies a
MOTW-tagged file into `\\wsl.localhost\...`, the 9P server can't attach an ADS
to the ext4 file and instead creates a literal sibling file: `name:Zone.Identifier`.

The common registry fix (`SaveZoneInformation=1`) doesn't help — it only
suppresses the old Attachment Execution Service path. Modern Chrome/Edge/VS Code
apply MOTW directly regardless of that policy.

## What this does

`bin/clean-zone-identifier.sh` runs `inotifywait` recursively on `$HOME` and
deletes any `*:Zone.Identifier` file the moment it's created — no matter which
Windows app wrote it, since Explorer/VS Code copies over `\\wsl.localhost\...`
land in the same underlying ext4 filesystem this script watches. It also does
a one-time sweep of existing artifacts on startup.

`systemd/zone-identifier-cleanup.service` runs it as a persistent user service.

## Install

```
sudo apt-get install -y inotify-tools

mkdir -p ~/.local/bin ~/.config/systemd/user
cp bin/clean-zone-identifier.sh ~/.local/bin/
chmod +x ~/.local/bin/clean-zone-identifier.sh
cp systemd/zone-identifier-cleanup.service ~/.config/systemd/user/

systemctl --user daemon-reload
systemctl --user enable --now zone-identifier-cleanup.service

# optional: start the service even if WSL boots without an interactive login
sudo loginctl enable-linger "$USER"
```

## Check it's running

```
systemctl --user status zone-identifier-cleanup.service
```
