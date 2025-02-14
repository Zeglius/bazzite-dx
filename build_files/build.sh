#!/usr/bin/bash
set -euo pipefail

trap '[[ $BASH_COMMAND != echo\ \"===* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

# RPM packages list
declare -A RPM_PACKAGES=(
  ["fedora"]="\
    android-tools \
    aria2 \
    bleachbit \
    cmatrix \
    croc \
    fish \
    gnome-disk-utility \
    gparted \
    htop \
    isoimagewriter \
    john \
    neovim \
    nmap \
    openrgb \
    powerline-fonts \
    qbittorrent \
    rclone \
    rustup \
    ShellCheck \
    shfmt \
    solaar \
    thefuck \
    tor \
    torbrowser-launcher \
    torsocks \
    virt-manager \
    virt-viewer \
    wireshark \
    yt-dlp \
    zsh"

  ["rpmfusion-free-updates"]="\
    audacious \
    audacious-plugins-freeworld \
    telegram-desktop"

  ["fedora-multimedia"]="\
    HandBrake-cli \
    HandBrake-gui \
    mpv \
    vlc"

  ["terra"]="\
    audacity-freeworld \
    coolercontrol \
    ghostty \
    hack-nerd-fonts \
    starship \
    ubuntu-nerd-fonts \
    ubuntumono-nerd-fonts"

  ["docker-ce"]="\
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin"

  ["brave-browser"]="brave-browser"
  ["cloudflare-warp"]="cloudflare-warp"
  ["signal-desktop"]="signal-desktop"
  ["vscode"]="code"

  ["copr:gloriouseggroll/nobara-41"]="\
    lact \
    scrcpy"
)

log "Starting Amy OS build process"

# Install RPM packages
log "Installing RPM packages"
for repo in "${!RPM_PACKAGES[@]}"; do
  read -ra pkg_array <<<"${RPM_PACKAGES[$repo]}"
  if [[ $repo == copr:* ]]; then
    # Handle COPR packages
    copr_repo=${repo#copr:}
    dnf5 -y copr enable "$copr_repo"
    dnf5 -y install "${pkg_array[@]}"
    dnf5 -y copr disable "$copr_repo"
  else
    # Handle regular packages
    [[ $repo != "fedora" ]] && enable_opt="--enable-repo=$repo" || enable_opt=""
    dnf5 -y install $enable_opt "${pkg_array[@]}"
  fi
done

# Install Cursor
log "Installing Cursor"
# GUI version
mkdir -p /tmp/cursor-gui
curl --retry 3 -Lo /tmp/cursor-gui/cursor.appimage "https://downloader.cursor.sh/linux/appImage/x64"
chmod +x /tmp/cursor-gui/cursor.appimage
cd /tmp/cursor-gui && ./cursor.appimage --appimage-extract
chmod -R a+rX /tmp/cursor-gui/squashfs-root
cp -r /tmp/cursor-gui/squashfs-root/usr/share/icons/hicolor/* /usr/share/icons/hicolor
rm -r /tmp/cursor-gui/squashfs-root/usr/share/icons/hicolor
mkdir -p /usr/share/cursor/bin
mv /tmp/cursor-gui/squashfs-root/* /usr/share/cursor
install -m 0755 /usr/share/cursor/resources/app/bin/cursor /usr/share/cursor/bin/cursor
ln -s /usr/share/cursor/bin/cursor /usr/bin/cursor
# CLI version
mkdir -p /tmp/cursor-cli
curl --retry 3 -Lo /tmp/cursor-cli/cursor-cli.tar.gz "https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64"
tar -xzf /tmp/cursor-cli/cursor-cli.tar.gz -C /tmp/cursor-cli
install -m 0755 /tmp/cursor-cli/cursor /usr/share/cursor/bin/cursor-tunnel
ln -s /usr/share/cursor/bin/cursor-tunnel /usr/bin/cursor-cli

# Enable services
log "Enabling system services"
systemctl enable docker libvirtd

# Disable autostart
log "Disabling autostart"
rm /etc/xdg/autostart/{solaar.desktop,com.cloudflare.WarpTaskbar.desktop}
rm /etc/skel/.config/autostart/steam.desktop

# Configure system
log "Configuring system"
echo "import \"/usr/share/amyos/just/install-apps.just\"" >>/usr/share/ublue-os/justfile
echo "eval \"\$(starship init bash)\"" >>/etc/bashrc
echo "eval \"\$(thefuck --alias)\"" >>/etc/bashrc
echo "starship init fish | source" >>/etc/fish/config.fish
echo "thefuck --alias | source" >>/etc/fish/config.fish

log "Build process completed"
