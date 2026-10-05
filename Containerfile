# PS5 Launcher OS: Bazzite's living-room edition (bazzite-deck) that logs straight into a
# Plasma session and opens PS5 Launcher full screen. Built by .github/workflows/os.yml; see
# os/README.md.
ARG BASE_IMAGE=ghcr.io/ublue-os/bazzite-deck:stable
FROM ${BASE_IMAGE}

# The latest launcher release (unpacked by the workflow). It only seeds each user's own copy in
# ~/.local/bin on first login; from then on the launcher updates itself there.
COPY launcher/ /usr/share/ps5-launcher-os/release/
COPY files/ /

# xdotool: switching between the launcher and a running game. mpv + yt-dlp: trailers.
RUN set -eux; \
    dnf5 -y install xdotool mpv yt-dlp; \
    dnf5 clean all; \
    chmod 0755 /usr/libexec/ps5-launcher-os/start /usr/share/ps5-launcher-os/release/ps5-launcher \
        /usr/share/ps5-launcher-os/release/install.sh; \
    # First-login pop-ups would cover the launcher.
    rm -f /etc/xdg/autostart/org.kde.plasma-welcome.desktop /etc/xdg/autostart/bazzite-announcement.desktop \
          /etc/skel/.config/autostart/bazzite-portal.desktop; \
    /usr/share/ps5-launcher-os/release/ps5-launcher --version; \
    rm -rf /var/cache/* /var/log/* /tmp/*; \
    bootc container lint || true

LABEL org.opencontainers.image.title="PS5 Launcher OS" \
      org.opencontainers.image.description="Bazzite that boots straight into PS5 Launcher" \
      org.opencontainers.image.source="https://github.com/MohamedAliRashad/ps5-launcher" \
      org.opencontainers.image.licenses="Apache-2.0"
