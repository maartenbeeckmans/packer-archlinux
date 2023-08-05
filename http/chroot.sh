#!/bin/sh
set -e
set -x

ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
hwclock --systohc
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'archlinux' > /etc/hostname

pacman --sync --noconfirm btrfs-progs

pacman --sync --noconfirm vim tree curl httpie wget htop iftop iotop tmux inetutils tar sed net-tools the_silver_searcher bind

echo 'root:secret' | chpasswd
