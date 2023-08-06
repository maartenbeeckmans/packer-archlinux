#!/bin/sh
set -e
set -x

pacman --sync --noconfirm mkinitcpio efibootmgr

mkdir -p /efi/EFI/arch/
if pacman -Qi linux; then
  cat <<-EOF >> /etc/systemd/system/efistub-update.path
  [Unit]
  Description=Copy EFISTUB lts Kernel to EFI system partition

  [Path]
  PathChanged=/boot/initramfs-linux-fallback.img

  [Install]
  WantedBy=multi-user.target
  WantedBy=system-update.target
EOF

  cat <<-EOF >> /etc/systemd/system/efistub-update.service
  [Unit]
  Description=Copy EFISTUB lts Kernel to EFI system partition

  [Service]
  Type=oneshot
  ExecStart=/usr/bin/cp -af /boot/vmlinuz-linux /efi/EFI/arch/
  ExecStart=/usr/bin/cp -af /boot/initramfs-linux.img /efi/EFI/arch/
  ExecStart=/usr/bin/cp -af /boot/initramfs-linux-fallback.img /efi/EFI/arch/
EOF

  systemctl daemon-reload
  systemctl enable efistub-update.path
  systemctl start efistub-update.path

  cp -af /boot/vmlinuz-linux /efi/EFI/arch/
  cp -af /boot/initramfs-linux.img /efi/EFI/arch/
  cp -af /boot/initramfs-linux-fallback.img /efi/EFI/arch/
fi

if pacman -Qi linux-lts; then
  cat <<-EOF >> /etc/systemd/system/efistub-lts-update.path
  [Unit]
  Description=Copy EFISTUB lts Kernel to EFI system partition

  [Path]
  PathChanged=/boot/initramfs-linux-lts-fallback.img

  [Install]
  WantedBy=multi-user.target
  WantedBy=system-update.target
EOF

  cat <<-EOF >> /etc/systemd/system/efistub-lts-update.service
  [Unit]
  Description=Copy EFISTUB lts Kernel to EFI system partition

  [Service]
  Type=oneshot
  ExecStart=/usr/bin/cp -af /boot/vmlinuz-linux-lts /efi/EFI/arch/
  ExecStart=/usr/bin/cp -af /boot/initramfs-linux-lts.img /efi/EFI/arch/
  ExecStart=/usr/bin/cp -af /boot/initramfs-linux-lts-fallback.img /efi/EFI/arch/
EOF

  systemctl daemon-reload
  systemctl enable efistub-lts-update.path
  systemctl start efistub-lts-update.path

  cp -afv /boot/vmlinuz-linux-lts /efi/EFI/arch/
  cp -afv /boot/initramfs-linux-lts.img /efi/EFI/arch/
  cp -afv /boot/initramfs-linux-lts-fallback.img /efi/EFI/arch/
fi



cat <<-EOF >> /sbin/create-efistub-boot-entry.sh
#!/bin/bash
#
# Script for creating boot records for ArchLinux
#

if pacman -Qi linux; then
  efibootmgr --create --gpt \
    --disk /dev/vda --part 1 \
    --label 'Arch Linux (EFISTUB)' \
    --loader '\EFI\arch\vmlinuz-linux' \
    --unicode "root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /) add_efi_memmap initrd=\EFI\arch\initramfs-linux.img"

  efibootmgr --create --gpt \
    --disk /dev/vda --part 1 \
    --label 'Arch Linux Fallback (EFISTUB)' \
    --loader '\EFI\arch\vmlinuz-linux' \
    --unicode "root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /) add_efi_memmap initrd=\EFI\arch\initramfs-linux-fallback.img"
fi

if pacman -Qi linux-lts; then
  efibootmgr --create --gpt \
    --disk /dev/vda --part 1 \
    --label 'Arch Linux lts (EFISTUB)' \
    --loader '\EFI\arch\vmlinuz-linux-lts' \
    --unicode "root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /) add_efi_memmap initrd=\EFI\arch\initramfs-linux-lts.img"

  efibootmgr --create --gpt \
    --disk /dev/vda --part 1\
    --label 'Arch Linux lts Fallback (EFISTUB)' \
    --loader '\EFI\arch\vmlinuz-linux-lts' \
    --unicode "root=UUID=$(findmnt -kno UUID /) rw rootfstype=$(findmnt -kno FSTYPE /) add_efi_memmap initrd=\EFI\arch\initramfs-linux-lts-fallback.img"
fi

efibootmgr --unicode
EOF

chmod +x /sbin/create-efistub-boot-entry.sh
/sbin/create-efistub-boot-entry.sh
