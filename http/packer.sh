#!/bin/sh

pacman --sync --needed --noconfirm cloud-init qemu-guest-agent sudo

useradd \
  --comment 'Maarten Beeckmans' \
  --defaults \
  --create-home \
  --shell /bin/bash \
  --user-group \
  --groups users,wheel \
  maartenb

passwd maartenb <<PASSWD
secret
secret
PASSWD

