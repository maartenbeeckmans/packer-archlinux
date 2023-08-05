#!/bin/sh
set -e
set -x

mkdir -p /efi/EFI/arch/
cat <<-EOF >> /etc/systemd/system/efistub-update.path
[Unit]
Description=Copy EFISTUB Kernel to EFI system partition

[Path]
PathChanged=/boot/initramfs-linux-lts-fallback.img

[Install]
WantedBy=multi-user.target
WantedBy=system-update.target
EOF

cat <<-EOF >> /etc/systemd/system/efistub-update.service
[Unit]
Description=Copy EFISTUB Kernel to EFI system partition

[Service]
Type=oneshot
ExecStart=/usr/bin/cp -af /boot/vmlinuz-linux-lts /efi/EFI/arch/
ExecStart=/usr/bin/cp -af /boot/initramfs-linux-lts.img /efi/EFI/arch/
ExecStart=/usr/bin/cp -af /boot/initramfs-linux-lts-fallback.img /efi/EFI/arch/
EOF

systemctl daemon-reload
systemctl enable efistub-update.path
systemctl start efistub-update.path

pacman --sync --noconfirm mkinitcpio linux-lts efibootmgr

/usr/bin/cp -afv /boot/vmlinuz-linux-lts /efi/EFI/arch/
/usr/bin/cp -afv /boot/initramfs-linux-lts.img /efi/EFI/arch/
/usr/bin/cp -afv /boot/initramfs-linux-lts-fallback.img /efi/EFI/arch/

efibootmgr --create --gpt \
  --disk /dev/vda --part 1 \
  --label 'Arch Linux (EFISTUB)' \
  --loader '\EFI\arch\vmlinuz-linux-lts' \
  --unicode "root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /) add_efi_memmap initrd=\EFI\arch\initramfs-linux-lts.img"
efibootmgr --create --gpt \
  --disk /dev/vda --part 1\
  --label 'Arch Linux Fallback (EFISTUB)' \
  --loader '\EFI\arch\vmlinuz-linux-lts' \
  --unicode "root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /) add_efi_memmap initrd=\EFI\arch\initramfs-linux-lts-fallback.img"

efibootmgr --unicode
