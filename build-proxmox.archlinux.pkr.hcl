locals {
  image_full_name = "${var.image_name}-${var.image_version}.${var.image_format}"
}

variable "image_name" {
  type = string
}

variable "image_version" {
  type = string
}

variable "image_format" {
  type    = string
  default = "qcow2"
}

variable "cpus" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 1024
}

variable "disk_size" {
  type    = string
  default = "30G"
}

variable "iso_checksum" {
  type = string
}

variable "iso_url" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_url" {
  type = string
}

variable "proxmox_username" {
  type = string
}

variable "proxmox_password" {
  type = string
}

source "proxmox-iso" "archlinux" {
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  iso_storage_pool = "local"
  unmount_iso      = true

  proxmox_url              = "${var.proxmox_url}"
  insecure_skip_tls_verify = true
  username                 = "${var.proxmox_username}"
  password                 = "${var.proxmox_password}"

  node = "${var.proxmox_node}"
  tags = "packer,${var.image_name}"

  cores  = "${var.cpus}"
  memory = "${var.memory}"
  os     = "l26"

  disks {
    disk_size    = "${var.disk_size}"
    storage_pool = "local-lvm"
    type         = "virtio"
  }

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  ssh_timeout  = "3600s"
  ssh_username = "root"
  ssh_password = "secret"

  template_description = "${local.image_full_name}, generated on ${timestamp()}"
  template_name        = "${local.image_full_name}"

  boot_command = [
    "<wait10><enter>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "<enter><wait>",
    "curl -sfSLO http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.sh<enter><wait>",
    "curl -sfSLO http://{{ .HTTPIP }}:{{ .HTTPPort }}/partition.sh<enter><wait>",
    "curl -sfSLO http://{{ .HTTPIP }}:{{ .HTTPPort }}/install-chroot.sh<enter><wait>",
    "curl -sfSLO http://{{ .HTTPIP }}:{{ .HTTPPort }}/packer.sh<enter><wait>",
    "chmod +x *.sh<enter>",
    "./install.sh<enter>"
  ]
  boot_wait      = "10s"
  http_directory = "./http"

  bios = "ovmf"
  efi_config {
    efi_storage_pool  = "local-lvm"
    pre_enrolled_keys = false
    efi_type          = "4m"
  }
}

build {
  sources = [
    "source.proxmox-iso.archlinux"
  ]
  provisioner "ansible" {
    playbook_file   = "provisioning/playbook.yml"
    extra_arguments = ["--scp-extra-args", "'-O'"]
  }
}