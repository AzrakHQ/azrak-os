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

## Minimal edition (os/minimal)

The same idea without Bazzite: Fedora's bootc base, Gamescope and the launcher, 2.9 GB instead of
~15, published as `:minimal`. No desktop; the launcher's **Settings → System** connects to Wi-Fi,
pairs controllers, picks the sound output, restarts, shuts down and offers system updates (it
knows it's on the OS from `/usr/lib/ps5-launcher-os/release`).

| File | What it does |
|---|---|
| [minimal/Containerfile](minimal/Containerfile) | The image: drivers and firmware, Gamescope, cage, greetd, NetworkManager, BlueZ, PipeWire, the launcher's and emulators' libraries. |
| `minimal/files/etc/greetd/config.toml`, `…/libexec/ps5-launcher-os/session` | Log `player` in at boot and run the launcher in Gamescope's Steam mode (switching between launcher and game uses its focus atoms). If Gamescope can't drive the graphics card, the launcher runs in cage so Settings → This PC can explain. The launcher is restarted if it ends. |
| `minimal/files/usr/lib/sysusers.d/…` | The `player` user (uid 1000, no password). |
| `minimal/files/usr/lib/systemd/system/ps5-launcher-os-update.*` | Daily `bootc upgrade`: downloads only. Fedora's own update timer restarts the PC and is masked. |
| `minimal/files/usr/lib/bootc/{install,kargs.d}/…` | XFS root, quiet boot, and `systemd.gpt_auto=0` (otherwise the EFI partition is mounted over `/boot` and updates fail to finish). |

Not yet: a live USB and an installer for it, and the proprietary NVIDIA driver (NVIDIA cards use
Mesa's NVK, which needs a GTX 16xx/RTX 20xx or newer).

Test it in a VM: `bootc install to-disk --via-loopback --generic-image` from the image (in a
privileged container), then boot the disk with UEFI. A VM has no GPU Vulkan, so the launcher
shows in cage there.

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
