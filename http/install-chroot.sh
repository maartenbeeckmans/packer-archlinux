#!/bin/sh
set -e
set -x

ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
hwclock --systohc
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'archlinux' > /etc/hostname

pacman --sync --noconfirm btrfs-progs vim less tree curl httpie wget htop iftop iotop tmux inetutils tar sed net-tools the_silver_searcher bind bash-completion openssh dhclient zram-generator

sed -i -e "s/.*ParallelDownloads.*/ParallelDownloads = 10/g" /etc/pacman.conf
sed -i -e "s/.*Color.*/Color/g" /etc/pacman.conf
sed -i -e "s/.*CheckSpace.*/CheckSpace/g" /etc/pacman.conf
sed -i -e "s/.*VerbosePkgLists.*/VerbosePkgLists/g" /etc/pacman.conf
sed -i -e "s/.*TotalDownload.*/TotalDownload/g" /etc/pacman.conf

echo 'root:secret' | chpasswd

sed -i -e 's/DNS=.*/DNS=1.1.1.1 1.0.0.1/g' /etc/systemd/resolved.conf
sed -i -e 's/FallbackDNS=.*/FallbackDNS=8.8.8.8 8.8.4.4/g' /etc/systemd/resolved.conf

systemctl enable systemd-resolved

default_interface=$(ip route get 1.1.1.1 | grep -Po '(?<=(dev ))(\S+)')

touch "/etc/systemd/network/10-${default_interface}.network"
printf '[Match]\nName=%s\n\n[Network]\nDHCP=yes\n' "${default_interface}" > "/etc/systemd/network/10-${default_interface}.network"

systemctl enable systemd-networkd

sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
systemctl enable sshd

if pacman -Qi linux; then
  mkinitcpio -p linux
fi

if pacman -Qi linux-lts; then
  mkinitcpio -p linux-lts
fi

bootctl --path=/boot install

if pacman -Qi linux; then
  cat <<-EOF >> /boot/loader/loader.conf
  default arch
  timeout 3
EOF

  cat <<-EOF >> /boot/loader/entries/arch.conf
  title Arch Linux
  linux /vmlinuz-linux
  initrd /initramfs-linux.img
  options root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /)
EOF

  cat <<-EOF >> /boot/loader/entries/arch-fallback.conf
  title Arch Linux Fallback
  linux /vmlinuz-linux
  initrd /initramfs-linux-fallback.img
  options root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /)
EOF
fi

if pacman -Qi linux-lts; then
  cat <<-EOF >> /boot/loader/loader.conf
  default arch-lts
  timeout 3
EOF

  cat <<-EOF >> /boot/loader/entries/arch-lts.conf
  title Arch Linux LTS
  linux /vmlinuz-linux-lts
  initrd /initramfs-linux-lts.img
  options root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /)
EOF

  cat <<-EOF >> /boot/loader/entries/arch-lts-fallback.conf
  title Arch Linux LTS Fallback
  linux /vmlinuz-linux-lts
  initrd /initramfs-linux-lts-fallback.img
  options root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /)
EOF
fi

cat <<-EOF >> /etc/systemd/zram-generator.conf
# /tmp
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
mount-point = /tmp
options = defaults,rw,nosuid,nodev,noexec,relatime

# /var/tmp
[zram1]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
mount-point = /var/tmp
options = defaults,rw,nosuid,nodev,noexec,relatime
EOF

systemctl daemon-reload

systemctl enable --now systemd-zram-setup@zram0.service systemd-zram-setup@zram1.service