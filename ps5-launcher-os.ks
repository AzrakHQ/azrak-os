# PS5 Launcher OS installer (Fedora's network installer + this file; see os/build-iso.sh).
# The installer asks for the disk and creates your user; everything else is set here. The OS
# itself is downloaded from GitHub's container registry, so an internet connection is needed.

# Answered here so the installer only asks for what matters: the disk, your user, and your time
# zone (for the launcher's clock). No root password: your user can administer the system.
keyboard --vckeymap=us --xlayouts=us
rootpw --lock

# The image for this PC: the NVIDIA build when an NVIDIA graphics card is present.
%pre --log=/tmp/ps5-launcher-os-pre.log
image=ghcr.io/mohamedalirashad/ps5-launcher-os
tag=stable
for dev in /sys/bus/pci/devices/*; do
    if [ "$(cat "$dev/vendor")" = 0x10de ] && grep -q '^0x03' "$dev/class"; then
        tag=nvidia
    fi
done
echo "Installing $image:$tag"
echo "ostreecontainer --url=$image:$tag --transport=registry --no-signature-verification" > /tmp/ps5-launcher-os-source.ks
%end
%include /tmp/ps5-launcher-os-source.ks

# Bazzite's kernel is signed with Universal Blue's key. With Secure Boot on, queue that key for
# enrollment: after the restart a blue "MOK management" screen asks to enroll it (password
# universalblue). With Secure Boot off, nothing is shown.
%post --nochroot --log=/tmp/ps5-launcher-os-secureboot.log
set -u
if [ ! -d /sys/firmware/efi ] || ! command -v mokutil >/dev/null; then
    echo "No UEFI or mokutil: skipping"; exit 0
fi
if ! mokutil --sb-state 2>/dev/null | grep -qi "SecureBoot enabled"; then
    echo "Secure Boot is off: nothing to enroll"; exit 0
fi
key=/tmp/ublue-secure-boot.der
curl -fsSL --retry 3 -o "$key" https://github.com/ublue-os/akmods/raw/main/certs/public_key.der || exit 0
mokutil --timeout -1 || :
printf 'universalblue\nuniversalblue\n' | mokutil --import "$key" || :
%end
