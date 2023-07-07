# Общие
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      # version = "0.80"
    }
  }
  # После установки backend terraform.tfstate ушел на хранение в bucket
  # -->
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "prj-bucket"
    key        = "terraform.tfstate"
    region     = "ru-central1"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
  # <--
  required_version = ">= 0.13"
}

provider "yandex" {
  token = var.yandex_token
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}