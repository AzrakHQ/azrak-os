#!/usr/bin/bash
# Build the AzrakOS USB stick image: AzrakOS itself, started from the stick (live/Containerfile),
# with the system the installer copies stored on it, so installing needs no internet. UEFI only,
# Secure Boot works (Fedora's signed shim, GRUB and kernel). No visible boot menu: hold Esc or
# Shift while the PC starts to see it.
# Runs in a privileged Fedora bootc container with the core image in its container storage:
#   podman run --rm --privileged -v /var/lib/containers:/var/lib/containers -v "$PWD:/src" -w /src \
#     quay.io/fedora/fedora-bootc:44 ./build-live-iso.sh OUT.iso
# CORE (default ghcr.io/azrakhq/azrak-os:minimal) is the image to start from and to install.
set -euo pipefail
out=${1:?output ISO}
core=${CORE:-ghcr.io/azrakhq/azrak-os:minimal}
label=AZRAKOS
work=${WORK:-$(mktemp -d /var/tmp/azrak-iso.XXXXXX)}

dnf5 -y -q install --setopt=install_weak_deps=False xorriso squashfs-tools dosfstools mtools >/dev/null

podman build --build-arg CORE="$core" -f live/Containerfile -t localhost/azrak-os:live .

# The install screens are the launcher's (docs/AZRAKOS.md in azrak-launcher): a stick whose
# launcher has none (an older release) couldn't install anything.
if ! podman run --rm --entrypoint /usr/share/azrak-os/release/azrak localhost/azrak-os:live --supports os-install; then
    echo "error: the launcher in $core can't install AzrakOS (azrak --supports os-install): release one that can, rebuild $core, then the stick" >&2
    exit 1
fi

# The live system's files.
rm -rf "$work/rootfs" "$work/iso" && mkdir -p "$work/rootfs" "$work/iso/LiveOS" "$work/iso/images/pxeboot" "$work/iso/EFI/BOOT"
cid=$(podman create localhost/azrak-os:live /bin/true)
podman export "$cid" | tar -C "$work/rootfs" -xf - --xattrs --numeric-owner
podman rm "$cid" >/dev/null

# The system the installer copies, as a read-only image store on the stick (live/files/etc/
# containers/storage.conf). Its files are mostly the live system's own, which mksquashfs stores once.
store=$work/rootfs/usr/lib/azrak-os/images
mkdir -p "$store"
podman push "$core" "containers-storage:[overlay@$store+/run/azrak-iso-storage]$core"
rm -rf "$store"/overlay/*/merged "$store"/overlay/*/work 2>/dev/null || :

kver=$(cd "$work/rootfs/usr/lib/modules" && echo *)
cp "$work/rootfs/usr/lib/modules/$kver/vmlinuz" "$work/iso/images/pxeboot/vmlinuz"
cp "$work/rootfs/usr/lib/modules/$kver/initramfs.img" "$work/iso/images/pxeboot/initrd.img"

mksquashfs "$work/rootfs" "$work/iso/LiveOS/squashfs.img" -noappend -comp zstd -Xcompression-level 19 -b 1M \
    -e sysroot -e ostree -quiet

# UEFI boot: Fedora's signed shim starts its signed GRUB, which reads grub.cfg next to it.
efi=$work/rootfs/usr/lib/efi
cp "$(ls "$efi"/shim/*/EFI/BOOT/BOOTX64.EFI | head -1)" "$work/iso/EFI/BOOT/BOOTX64.EFI"
cp "$(ls "$efi"/shim/*/EFI/fedora/mmx64.efi | head -1)" "$work/iso/EFI/BOOT/mmx64.efi"
cp "$(ls "$efi"/grub2/*/EFI/fedora/gcdx64.efi | head -1)" "$work/iso/EFI/BOOT/grubx64.efi"
args="root=live:CDLABEL=$label rd.live.image rd.live.overlay.overlayfs=1 enforcing=0 quiet splash loglevel=3 rd.udev.log_level=3 systemd.show_status=auto vt.global_cursor_default=0"
cat > "$work/iso/EFI/BOOT/grub.cfg" <<EOF
set default=0
set timeout_style=hidden
set timeout=1
search --no-floppy --set=root --label $label
menuentry 'AzrakOS' {
    linux /images/pxeboot/vmlinuz $args
    initrd /images/pxeboot/initrd.img
}
menuentry 'AzrakOS (basic graphics)' {
    linux /images/pxeboot/vmlinuz $args nomodeset
    initrd /images/pxeboot/initrd.img
}
EOF
mkdir -p "$work/iso/EFI/fedora" && cp "$work/iso/EFI/BOOT/grub.cfg" "$work/iso/EFI/fedora/grub.cfg"

# The EFI system partition image (El Torito, and appended as a GPT partition for USB sticks).
esp=$work/efiboot.img
rm -f "$esp" && truncate -s 16M "$esp" && mkfs.vfat -n AZRAKEFI "$esp" >/dev/null
mmd -i "$esp" ::/EFI ::/EFI/BOOT ::/EFI/fedora
mcopy -i "$esp" "$work/iso/EFI/BOOT/"* ::/EFI/BOOT/
mcopy -i "$esp" "$work/iso/EFI/fedora/grub.cfg" ::/EFI/fedora/
cp "$esp" "$work/iso/images/efiboot.img"

rm -f "$out"
xorriso -as mkisofs -o "$out" -V "$label" -iso-level 3 -full-iso9660-filenames -joliet -joliet-long -rational-rock \
    -partition_offset 16 -append_partition 2 0xef "$esp" -appended_part_as_gpt \
    -e --interval:appended_partition_2:all:: -no-emul-boot \
    "$work/iso"
ls -la "$out"
