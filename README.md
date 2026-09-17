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

`clean-zone-identifier.sh` runs `inotifywait` recursively on `$HOME` and
deletes any `*:Zone.Identifier` file the moment it's created — no matter which
Windows app wrote it, since Explorer/VS Code copies over `\\wsl.localhost\...`
land in the same underlying ext4 filesystem this script watches. It also does
a one-time sweep of existing artifacts on startup.

`zone-identifier-cleanup.service` runs it as a persistent user service.

## Requirements

- WSL2 (not WSL1)
- systemd enabled (`systemd=true` in `/etc/wsl.conf`)
- Debian/Ubuntu-based distro (swap `apt-get` for `dnf`/`zypper` otherwise)
- `$HOME` on the WSL ext4 disk, not a network share or `/mnt/c`
- Install separately per distro/machine — nothing syncs

## Install

### Windows installer (no command line)

Download `wsl-zone-cleanup-setup.exe` from the [latest release](https://github.com/ilee07/wsl-zone-cleanup/releases/latest)
and double-click it. It installs the files, then runs `install.sh` inside
your default WSL distro for you — you'll be prompted once for your Linux
sudo password in the console window it opens.

### Scripted (from inside WSL)

```
./install.sh
```

### Manual

```
sudo apt-get install -y inotify-tools

mkdir -p ~/.local/bin ~/.config/systemd/user
cp clean-zone-identifier.sh ~/.local/bin/
chmod +x ~/.local/bin/clean-zone-identifier.sh
cp zone-identifier-cleanup.service ~/.config/systemd/user/

systemctl --user daemon-reload
systemctl --user enable --now zone-identifier-cleanup.service

# optional: start the service even if WSL boots without an interactive login
sudo loginctl enable-linger "$USER"
```

## Check it's running

```
systemctl --user status zone-identifier-cleanup.service
```
