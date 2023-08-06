#!/bin/bash
#
# Script used for bootstrapping created ArchLinux image
#
GUEST_NAME="${1:?Provide a guest name}"

echo "Bootstrapping vm ${GUEST_NAME}"

sudo cp -rfv ../packer_builds/efivars.fd "/var/lib/libvirt/qemu/nvram/${GUEST_NAME}.fd"
sudo cp -rfv ../packer_builds/archlinux-1.0.qcow2 "/var/lib/libvirt/images/${GUEST_NAME}.qcow2"

sudo virt-install \
  --connect qemu:///system \
  --name "${GUEST_NAME}" \
  --vcpus 2 \
  --memory 2048 \
  --noautoconsole \
  --cpu host \
  --os-variant archlinux  \
  --import  \
  --accelerate \
  --vnc \
  --hvm \
  --disk "/var/lib/libvirt/images/${GUEST_NAME}.qcow2,format=qcow2,bus=virtio" \
  --network bridge=virbr0,model=virtio  \
  --cloud-init root-password-generate=off \
  --boot "loader=/usr/share/OVMF/x64/OVMF_CODE.fd,loader.readonly=yes,loader.secure=no,loader.type=pflash,nvram.template=/usr/share/OVMF/x64/OVMF_VARS.fd,nvram=/var/lib/libvirt/qemu/nvram/${GUEST_NAME}.fd"
