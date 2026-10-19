# AzrakOS: how it's built

A PC that starts straight into [Azrak Launcher](https://github.com/AzrakHQ/azrak-launcher). This
page is for people working on it; players start at the [README](../README.md).

There are three images and one USB stick:

| | What | Published as |
|---|---|---|
| Minimal edition ([minimal/](../minimal/)) | Fedora's smallest bootable system, Gamescope and the launcher: no desktop | `ghcr.io/azrakhq/azrak-os:minimal` (1.25 GB download) |
| NVIDIA version ([nvidia/](../nvidia/)) | The minimal edition plus NVIDIA's driver, as layers on top | `:minimal-nvidia` (814 MB more, only for NVIDIA PCs) |
| USB stick ([live/](../live/), [build-live-iso.sh](../build-live-iso.sh)) | AzrakOS started from the stick: try it, or install it from the launcher | `azrak-os-x86_64.iso` in the [releases](https://github.com/AzrakHQ/azrak-os/releases) (1.8 GB) |
| Bazzite editions ([Containerfile](../Containerfile)) | Bazzite's living-room edition with the launcher | `:stable`, `:nvidia` (about 7 GB) |

The launcher is the whole screen, so the OS's own screens (Settings → SYSTEM, installing from the
stick) are the launcher's. What each side expects from the other (the marker file, the
installer's protocol, the permissions, `azrak --supports`) is in
[azrak-launcher: docs/AZRAKOS.md](https://github.com/AzrakHQ/azrak-launcher/blob/main/docs/AZRAKOS.md).

## Minimal edition (minimal/)

| File | What it does |
|---|---|
| [minimal/Containerfile](../minimal/Containerfile) | Fedora's minimal bootc set (`bootc-base-imagectl build-rootfs --manifest=minimal`: bootc, systemd, the kernel, dnf), then drivers and firmware, Gamescope, cage, greetd, NetworkManager, BlueZ, PipeWire, the boot screen, and what the launcher and emulators load. Universal Blue's kernel-module key is stored for the NVIDIA version. os-release says AzrakOS. |
| `minimal/files/etc/greetd/config.toml`, `…/libexec/azrak-os/session` | Log `player` in at boot and run the launcher in Gamescope's Steam mode (switching between launcher and game uses its focus atoms). If Gamescope can't drive the graphics card, the launcher runs in cage so Settings → This PC can explain. The launcher is restarted if it ends, and copied again from the image if its copy doesn't run. |
| `minimal/files/usr/share/plymouth/themes/azrak/` | The boot screen: the Azrak logo on the launcher's background (Fedora's spinner images are copied in at build time). |
| `minimal/files/usr/share/polkit-1/rules.d/50-azrak-os.rules` | `player`, at the PC, manages the network (joining a new Wi-Fi network needs it). |
| `minimal/files/usr/lib/sysusers.d/…` | The `player` user (uid 1000, no password). |
| `minimal/files/usr/libexec/azrak-os/update`, `…/systemd/system/azrak-os-update.*` | Daily, from 3 minutes after starting (and every 15 minutes while offline): stage the next version, and the right one for the graphics card (an NVIDIA PC switches to `:minimal-nvidia`; with Secure Boot on only once Universal Blue's key is enrolled, which it queues). Downloads only; Fedora's own timer, which restarts the PC, is masked. |
| `minimal/files/usr/lib/bootc/{install,kargs.d}/…` | XFS root, quiet boot with the splash, and `systemd.gpt_auto=0` (otherwise the EFI partition is mounted over `/boot` and updates fail to finish). |

The build is a `FROM scratch` image, so the workflow splits it into one layer per package
(`bootc-base-imagectl rechunk`, timestamps zeroed): a daily rebuild only changes the layers whose
packages changed, and that's all a PC downloads.

The session only uses Gamescope with a launcher that supports it (`azrak --supports gamescope`);
an older one runs in cage until it updates itself. For the same reason the workflow publishes
`:minimal` only once the latest launcher release supports it.

## NVIDIA version (nvidia/)

NVIDIA's 580 driver series (today's cards and the GTX 900/1000 ones newer series dropped) from
Universal Blue's `akmods-nvidia-lts`, built for the minimal edition's exact kernel and signed
with their key. The workflow builds it right after `:minimal`, for that image's kernel; until
Universal Blue has modules for a new kernel (usually within a day) it keeps the previous one.
No CUDA tools, settings app or 32-bit libraries; nouveau off, kernel modesetting on.

Nobody picks it: the installer installs it on an NVIDIA PC with internet (downloading only the
driver layers), and otherwise the installed PC switches to it by itself (`azrak-os/update`).

## USB stick (live/, build-live-iso.sh)

The minimal edition started from the stick (dracut's `dmsquash-live`, changes kept in memory),
with Fedora's signed shim, GRUB and kernel, so Secure Boot works. No boot menu in sight (hold Esc
or Shift for it). The launcher sees it's on the stick and starts with "Welcome to AzrakOS": try
it, or install it.

- The system the installer copies is stored on the stick as a read-only image store
  (`/usr/lib/azrak-os/images`); its files are the live system's own, which mksquashfs stores once.
  Podman's own storage is in memory on the stick.
- [live/files/usr/libexec/azrak-os/install](../live/files/usr/libexec/azrak-os/install) lists the
  disks and installs (`bootc install to-disk` from the stored image: no internet needed), with
  NVIDIA's driver when it applies. A polkit rule lets `player` run it, on the stick only.
- `build-live-iso.sh` refuses a launcher without the install screens
  (`azrak --supports os-install`), so release the launcher before an OS change that needs it.

## Bazzite editions

[Containerfile](../Containerfile) with [files/](../files/): `bazzite-deck` (or
`bazzite-deck-nvidia`), logging straight into a Plasma session with the launcher full screen
(no lock screen, KDE Wallet or automatic suspend). Still built daily for the PCs that have them.
Their installer (Fedora's network installer with a kickstart) is gone: the USB stick installs
the minimal edition. It's in the git history before the USB stick, if it's ever needed.

## Updates

- **OS:** installed machines update from `ghcr.io/azrakhq/azrak-os:<edition>` in the background.
  A bad update can be undone from the boot menu.
- **Launcher, KytyPS5, shadPS4:** in the user's home folder; the launcher updates them itself.
  The copy in the image only seeds a new user.

## Build and test locally

The minimal edition and the stick need a privileged Fedora bootc container with podman (`podman`
builds `FROM scratch` with bootc-base-imagectl, and rechunks):

```bash
podman build --cap-add=all --security-opt=label=disable --device /dev/fuse -f minimal/Containerfile -t localhost/azrak-os:core-build .
podman run --rm --privileged -v /var/lib/containers:/var/lib/containers quay.io/fedora/fedora-bootc:44 \
  /usr/libexec/bootc-base-imagectl rechunk localhost/azrak-os:core-build ghcr.io/azrakhq/azrak-os:minimal
podman run --rm --privileged -v /var/lib/containers:/var/lib/containers -v "$PWD:/src" -w /src \
  quay.io/fedora/fedora-bootc:44 ./build-live-iso.sh azrak-os-x86_64.iso
```

Put the launcher to bundle in `launcher/` first (the workflow unpacks the latest release there).
Boot the ISO in a UEFI VM as a USB stick (QEMU: `-device usb-storage`, OVMF with Secure Boot,
6 GB RAM, an empty disk) and install from the launcher. A VM has no GPU Vulkan, so the launcher
shows in cage there, and draws slowly.
