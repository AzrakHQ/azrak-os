# PS5 Launcher OS

A PC that starts straight into PS5 Launcher: [Bazzite](https://bazzite.gg)'s living-room edition
(`bazzite-deck`) with the launcher added. Players see the README's "Turn a spare PC into a
console" section; this is how it's built.

## Pieces

| File | What it does |
|---|---|
| [Containerfile](Containerfile) | The OS image: `bazzite-deck` (or `bazzite-deck-nvidia`) + the latest launcher release, xdotool, mpv, yt-dlp, and the files below. |
| [files/etc/bazzite/desktop_autologin](files/etc/bazzite/desktop_autologin) | Bazzite's own marker: its `bazzite-autologin` service logs user 1000 into Plasma instead of Steam Gaming Mode. |
| [files/etc/xdg/autostart/ps5-launcher-os.desktop](files/etc/xdg/autostart/ps5-launcher-os.desktop), [files/usr/libexec/ps5-launcher-os/start](files/usr/libexec/ps5-launcher-os/start) | Opens the launcher full screen when the session starts. On first login it installs the launcher into `~/.local/bin` (from the copy in the image) so it can update itself there. It runs on XWayland, because switching between the launcher and a game uses xdotool. |
| `files/etc/xdg/{kscreenlockerrc,powerdevilrc,kwalletrc}` | No lock screen, no KDE Wallet prompts (nothing to type them with on a controller), no automatic suspend (downloads keep going). |
| [ps5-launcher-os.ks](ps5-launcher-os.ks) | Kickstart for Fedora's network installer: installs `ghcr.io/mohamedalirashad/ps5-launcher-os:stable`, or `:nvidia` when an NVIDIA graphics card is present, and queues Bazzite's Secure Boot key (password `universalblue`) when Secure Boot is on. The installer still asks for the disk and creates the user. |
| [build-iso.sh](build-iso.sh) | Fedora 44's netinstall ISO + the kickstart, with the boot menu renamed: about 1.2 GB, so it fits a GitHub release (2 GB per file). Bazzite's own ISO embeds the whole OS (~8 GB). |
| [../.github/workflows/os.yml](../.github/workflows/os.yml) | Builds, checks and pushes both images (daily, so installed machines get Bazzite's updates, and after each launcher release), then builds the ISO and attaches it to the latest release. |

## Updates

- **OS:** installed machines update from `ghcr.io/mohamedalirashad/ps5-launcher-os:<stable|nvidia>`
  in the background, like Bazzite. A bad update can be undone from the boot menu.
- **Launcher, KytyPS5, shadPS4:** in the user's home folder; the launcher updates them itself.
  The copy in the image only seeds a new user.

## Build and test locally

```bash
# The ISO (in a Fedora container, which has mkksiso):
docker run --rm --privileged -v "$PWD:/src" -w /src fedora:44 os/build-iso.sh ps5-launcher-os-x86_64.iso
# An unattended test ISO: append a kickstart with the disk, user and "reboot" answered, e.g.
#   lang/keyboard/timezone, zerombr, clearpart --all, autopart, user --name=..., reboot
docker run --rm --privileged -v "$PWD:/src" -w /src fedora:44 os/build-iso.sh test.iso test-answers.ks
```

Boot it in a UEFI VM (QEMU + OVMF, 8 GB RAM, 80 GB disk, network). The VM test checks that the
first boot logs in by itself and opens the launcher full screen, that the launcher lives in
`~/.local/bin` and updates itself, and that switching to a game window and back works.
