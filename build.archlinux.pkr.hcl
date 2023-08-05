###########
## Build ##
###########
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
