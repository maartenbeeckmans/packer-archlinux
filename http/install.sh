#!/bin/sh

set -ex
set -x

DEVICE=/dev/vda

timedatectl set-ntp true

# Force synchronisation of package database (so we can install things later, if necessary).
pacman --sync --refresh --refresh

./partition.sh "${DEVICE}"

pacstrap /mnt base linux-lts

# Generate an fstab file with UUID
genfstab -t UUID /mnt >> /mnt/etc/fstab

cp chroot.sh /mnt/
arch-chroot /mnt /chroot.sh
rm /mnt/chroot.sh

cp efistub.sh /mnt/
arch-chroot /mnt /efistub.sh
rm /mnt/efistub.sh

cp network.sh /mnt/
arch-chroot /mnt /network.sh
rm /mnt/network.sh

cp packer.sh /mnt/
arch-chroot /mnt /packer.sh
rm /mnt/packer.sh

swapoff -a
umount -R /mnt
systemctl reboot
