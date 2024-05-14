#/bin/bash
# https://gist.github.com/allisson/7ff8487b696fd30c4767341d3d797595
snap remove --purge firefox
snap remove --purge snap-store
snap remove --purge snapd-desktop-integration
snap remove --purge gtk-common-themes
snap remove --purge gnome-3-38-2004
snap remove --purge core20
snap remove --purge bare
snap remove --purge snapd
apt remove -y --purge snapd
apt-mark hold snapd # avoid install snapd again
apt-mark hold gnome-software-plugin-snap # avoid install this plugin
apt install -y gnome-software gnome-software-plugin-flatpak

#https://askubuntu.com/questions/1345385/how-can-i-stop-apt-from-installing-snap-packages
apt autopurge snapd
#and then create special configuration file for APT, as LinuxMint did:
cat <<EOF | sudo tee /etc/apt/preferences.d/nosnap.pref
# To prevent repository packages from triggering the installation of Snap,
# this file forbids snapd from being installed by APT.
# For more information: https://linuxmint-user-guide.readthedocs.io/en/latest/snap.html

Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
