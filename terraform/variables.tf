
# General
variable "yandex_token" {
  description   = "yandex_token"
  type          = string
  default = "AQAAAABeagchAATuwY8-jsMf5EZol-5ZsgRddA8"
}
variable "cloud_id" {
  default = "b1goon3q207eivvefts0"
}
variable "folder_id" {
  default = "b1gkgthf18fqkuii66ht"
}
variable "zone" {
  default = "ru-central1-b"
}
variable "user" {
  default = "locadm"
}
variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}
variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}
variable "disk_image_id" {
  default = "fd87va5cc00gaq2f5qfb"
}

# All VPS config
