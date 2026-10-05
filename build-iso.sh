#!/usr/bin/bash
# Build the PS5 Launcher OS installer ISO: Fedora's network installer with os/ps5-launcher-os.ks.
# Runs in a Fedora container (needs lorax's mkksiso):
#   docker run --rm --privileged -v "$PWD:/src" -w /src fedora:44 os/build-iso.sh OUT.iso [EXTRA.ks]
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

ks=$(mktemp -d)/ps5-launcher-os.ks
cat os/ps5-launcher-os.ks > "$ks"
[ -n "$extra" ] && cat "$extra" >> "$ks"
rm -f "$out"
# The boot menu names our OS (the installer program is Fedora's; what it installs is
# Bazzite + PS5 Launcher), starts the plain install after 10 s, and skips the slow media check
# Fedora runs by default (-r rd.live.check).
mkksiso --ks "$ks" -V "PS5-Launcher-OS" -r rd.live.check \
    -R "Install Fedora 44" "Install PS5 Launcher OS" \
    -R "install Fedora 44" "install PS5 Launcher OS" \
    -R "Rescue a Fedora system" "Rescue an installed system" \
    -R 'set default="1"' 'set default="0"' \
    -R "set timeout=60" "set timeout=10" \
    "$cache/$iso" "$out"
ls -la "$out"
