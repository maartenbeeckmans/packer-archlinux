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

mv install-chroot.sh /mnt
arch-chroot /mnt /install-chroot.sh | tee /mnt/var/log/packer-install.log
rm -v /mnt/install-chroot.sh

mv packer.sh /mnt
arch-chroot /mnt /packer.sh | tee /mnt/var/log/packer-install.log
rm -v /mnt/packer.sh

swapoff -a
umount -R /mnt
systemctl reboot
