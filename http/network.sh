#!/bin/sh
set -e
set -x

ping -c 1 1.1.1.1

default_interface=$(ip route get 1.1.1.1 | grep -Po '(?<=(dev ))(\S+)')

touch "/etc/systemd/network/10-${default_interface}.network"
printf '[Match]\nName=%s\n\n[Network]\nDHCP=yes\n' "${default_interface}" > "/etc/systemd/network/10-${default_interface}.network"

sed -i -e 's/DNS=.*/DNS=1.1.1.1 1.0.0.1/g' /etc/systemd/resolved.conf
sed -i -e 's/FallbackDNS=.*/FallbackDNS=8.8.8.8 8.8.4.4/g' /etc/systemd/resolved.conf

systemctl enable systemd-resolved
systemctl enable systemd-networkd
