#!/bin/sh

pacman --sync --needed --noconfirm cloud-init qemu-guest-agent

pacman --sync --needed --noconfirm sudo

useradd maartenb \
  --comment 'Maarten Beeckmans' \
  --defaults \
  --create-home \
  --shell /bin/bash \
  --user-group \
  --groups users,wheel

passwd maartenb <<PASSWD
secret
secret
PASSWD

pacman --sync --needed --noconfirm openssh dhcpcd
sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
systemctl enable sshd
