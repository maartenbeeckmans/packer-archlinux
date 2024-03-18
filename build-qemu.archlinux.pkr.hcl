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
  default = "32G"
}

variable "headless" {
  type    = bool
  default = true
}

variable "iso_checksum" {
  type = string
}

variable "iso_url" {
  type = string
}

source "qemu" "archlinux" {
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
  boot_wait         = "10s"
  cpus              = "${var.cpus}"
  memory            = "${var.memory}"
  disk_size         = "${var.disk_size}"
  headless          = "${var.headless}"
  http_directory    = "./http"
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url}"
  output_directory  = "./packer_builds"
  shutdown_command  = "sudo systemctl poweroff"
  ssh_port          = 22
  ssh_timeout       = "3600s"
  ssh_username      = "root"
  ssh_password      = "secret"
  vm_name           = "${local.image_full_name}"
  accelerator       = "kvm"
  format            = "${var.image_format}"
  efi_boot          = true
  efi_firmware_code = "/usr/share/OVMF/x64/OVMF_CODE.fd"
  efi_firmware_vars = "/usr/share/OVMF/x64/OVMF_VARS.fd"
}

build {
  sources = ["source.qemu.archlinux"]
  post-processor "checksum" {
    checksum_types = [
      "sha256"
    ]
    keep_input_artifact = false
    output              = "./packer_builds/${local.image_full_name}.sha256"
  }
  post-processor "compress" {
    compression_level = 9
    output            = "./packer_builds/${local.image_full_name}.tar.gz"
  }
}