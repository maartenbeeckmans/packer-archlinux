#!/bin/sh
set -e
set -x

DEVICE="${1}"

efi_partition="${DEVICE}1"
btrfs_partition="${DEVICE}2"

# Partition efi
parted "${DEVICE}" --script mklabel gpt
parted "${DEVICE}" --script --align=optimal mkpart ESP fat32 1MiB 512MiB
parted "${DEVICE}" --script set 1 boot on
parted "${DEVICE}" --script --align=optimal mkpart primary btrfs 10GiB 100%

mkfs.fat -F 32 "${efi_partition}"
mkfs.btrfs -L 'root' "${btrfs_partition}"

# Btrfs setup
mount --types  btrfs \
  "${btrfs_partition}" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume set-default /mnt/@
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/var
btrfs subvolume create /mnt/var/log
btrfs subvolume create /mnt/var/log/audit
btrfs subvolume create /mnt/var/tmp
btrfs subvolume create /mnt/tmp
btrfs subvolume create /mnt/swap
btrfs filesystem mkswapfile --size 1G --uuid clear /mnt/swap/swapfile

sleep 2

umount -lAR /mnt

mount --types btrfs \
  --options defaults,compress=zstd,noatime,autodefrag,datacow,datasum \
  "${btrfs_partition}" /mnt
mount --types vfat \
  --mkdir \
  "${efi_partition}" /mnt/efi
mount --types btrfs \
  --mkdir \
  --options defaults,subvol=home,compress=zstd,noatime,autodefrag,datacow,datasum \
  "${btrfs_partition}" /mnt/home
mount --types btrfs \
  --mkdir \
  --options defaults,subvol=var,compress=zstd,noatime,autodefrag,datacow,datasum,nodev \
  "${btrfs_partition}" /mnt/var
mount --types btrfs \
  --mkdir \
  --options defaults,subvol=var/log,compress=zstd,noatime,autodefrag,datacow,datasum \
  "${btrfs_partition}" /mnt/var/log
mount --types btrfs \
  --mkdir \
  --options defaults,subvol=var/log/audit,compress=zstd,noatime,autodefrag,datacow,datasum \
  "${btrfs_partition}" /mnt/var/log/audit
mount --types btrfs \
  --mkdir \
  --options defaults,subvol=var/tmp,compress=zstd,rw,nosuid,nodev,noexec,relatime \
  "${btrfs_partition}" /mnt/var/tmp
mount --types btrfs \
  --mkdir \
  --options defaults,subvol=tmp,compress=zstd,rw,nosuid,nodev,noexec,relatime \
  "${btrfs_partition}" /mnt/tmp
mount --types btrfs \
  --mkdir \
  --options defaults,subvol=swap,compress=no,noatime,autodefrag,datacow,datasum \
  "${btrfs_partition}" /mnt/swap
swapon /mnt/swap/swapfile
