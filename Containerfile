# AzrakOS: Bazzite's living-room edition (bazzite-deck) that logs straight into a
# Plasma session and opens Azrak Launcher full screen. Built by .github/workflows/os.yml; see
# README.md.
ARG BASE_IMAGE=ghcr.io/ublue-os/bazzite-deck:stable
FROM ${BASE_IMAGE}

# The latest launcher release (unpacked by the workflow). It only seeds each user's own copy in
# ~/.local/bin on first login; from then on the launcher updates itself there.
COPY launcher/ /usr/share/azrak-os/release/
COPY files/ /

# xdotool: switching between the launcher and a running game. mpv-libs (libmpv) + yt-dlp: trailers.
RUN set -eux; \
    dnf5 -y install xdotool mpv mpv-libs yt-dlp; \
    dnf5 clean all; \
    systemctl enable azrak-os-ensure-user.service; \
    chmod 0755 /usr/libexec/azrak-os/start /usr/libexec/azrak-os/ensure-user \
        /usr/share/azrak-os/release/azrak \
        /usr/share/azrak-os/release/install.sh; \
    # Nothing may open over the launcher: first-login pop-ups, and Steam, which the living-room
    # edition starts (and updates) at every login. Steam stays in the app menu.
    rm -f /etc/xdg/autostart/org.kde.plasma-welcome.desktop /etc/xdg/autostart/bazzite-announcement.desktop \
          /etc/skel/.config/autostart/bazzite-portal.desktop /etc/xdg/autostart/steam.desktop; \
    # "Return to Gaming Mode" would make every later boot start Steam instead of the launcher.
    rm -f /etc/skel/Desktop/Return.desktop; \
    /usr/share/azrak-os/release/azrak --version; \
    rm -rf /var/cache/* /var/log/* /tmp/*; \
    bootc container lint || true

LABEL org.opencontainers.image.title="AzrakOS" \
      org.opencontainers.image.description="Bazzite that boots straight into Azrak Launcher" \
      org.opencontainers.image.source="https://github.com/AzrakHQ/azrak-os" \
      org.opencontainers.image.licenses="Apache-2.0"
