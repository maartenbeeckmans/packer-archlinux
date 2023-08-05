###############
## Variables ##
###############
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
