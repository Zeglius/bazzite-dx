#!/bin/bash

set -ouex pipefail

# Create directories
mkdir -p /var/opt

# Add repositories
dnf5 config-manager addrepo --from-repofile https://github.com/astrovm/amyos/raw/refs/heads/main/repo_files/vscode.repo
dnf5 config-manager addrepo --from-repofile https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
dnf5 config-manager addrepo --from-repofile https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo
dnf5 copr enable -y zeno/scrcpy
dnf5 copr enable -y codifryed/CoolerControl
dnf5 copr enable -y atim/ubuntu-fonts

# Install packages
dnf5 install -y \
    android-tools \
    aria2 \
    audacious \
    audacity \
    bleachbit \
    brave-browser \
    btop \
    cloudflare-warp \
    cmatrix \
    code \
    containerd.io \
    coolercontrol \
    croc \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    easyeffects \
    filelight \
    firefox \
    flatseal \
    gimp \
    gparted \
    gwenview \
    haruna \
    htop \
    isoimagewriter \
    gnome-disk-utility \
    mediawriter \
    john \
    kcalc \
    kdenlive \
    krita \
    lact \
    liquidctl \
    mpv \
    neovim \
    net-tools \
    nmap \
    okular \
    pinta \
    protontricks \
    protonvpn-cli \
    qbittorrent \
    rclone \
    scrcpy \
    solaar \
    syncthing \
    tor \
    torbrowser-launcher \
    torsocks \
    ubuntu-family-fonts \
    util-linux \
    virt-manager \
    vlc \
    wireshark \
    yt-dlp

# Clean cache
dnf5 clean all

# Move directories
mv /var/opt/brave.com /usr/lib/brave.com

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/brave-browser.conf <<EOF
L  /opt/brave.com -  -  -  -  /usr/lib/brave.com
EOF

# Enable services
systemctl enable docker
systemctl enable libvirtd
