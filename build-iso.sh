#!/usr/bin/bash
# Build the AzrakOS installer ISO: Fedora's network installer with azrak-os.ks.
# Runs in a Fedora container (needs lorax's mkksiso):
#   docker run --rm --privileged -v "$PWD:/src" -w /src fedora:44 ./build-iso.sh OUT.iso [EXTRA.ks]
# EXTRA.ks is appended to the kickstart (the automated VM test uses it; releases don't).
set -euo pipefail
out=${1:?output ISO}
extra=${2:-}
release=44
version=44-1.7
iso=Fedora-Everything-netinst-x86_64-$version.iso
base=https://dl.fedoraproject.org/pub/fedora/linux/releases/$release/Everything/x86_64/iso
cache=${ISO_CACHE:-/tmp}

dnf -y -q install lorax xorriso curl >/dev/null
if [ ! -f "$cache/$iso" ]; then
    curl -fsSL --retry 3 -o "$cache/$iso" "$base/$iso"
fi
curl -fsSL --retry 3 -o "$cache/CHECKSUM" "$base/Fedora-Everything-$version-x86_64-CHECKSUM"
(cd "$cache" && sha256sum -c --ignore-missing CHECKSUM | grep -q ": OK")

# Universal Blue's kernel-signing key, which Bazzite's kernel needs with Secure Boot on.
key_url=https://github.com/ublue-os/akmods/raw/main/certs/public_key.der
key_sha256=4e5c68474cb133fd8984d9599762cece9100c3e6cd8a9709aeaabd85dd9e70d1
files=$(mktemp -d)
curl -fsSL --retry 3 -o "$files/azrak-os-secureboot.der" "$key_url"
echo "$key_sha256  $files/azrak-os-secureboot.der" | sha256sum -c -

ks=$(mktemp -d)/azrak-os.ks
cat azrak-os.ks > "$ks"
[ -n "$extra" ] && cat "$extra" >> "$ks"
rm -f "$out"
# The boot menu names our OS (the installer program is Fedora's; what it installs is
# Bazzite + Azrak Launcher), starts the plain install after 10 s, and skips the slow media check
# Fedora runs by default (-r rd.live.check).
mkksiso --ks "$ks" -V "PS5-Launcher-OS" -r rd.live.check \
    -R "Install Fedora 44" "Install AzrakOS" \
    -R "install Fedora 44" "install AzrakOS" \
    -R "Rescue a Fedora system" "Enroll the Secure Boot key again" \
    -R "inst.rescue" "ps5los.enroll" \
    -a "$files/azrak-os-secureboot.der" \
    -R 'set default="1"' 'set default="0"' \
    -R "set timeout=60" "set timeout=10" \
    "$cache/$iso" "$out"
ls -la "$out"
