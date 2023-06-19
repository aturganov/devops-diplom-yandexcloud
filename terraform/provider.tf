# Общие
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  # -->
  # После установки backend terraform.tfstate ушел на хранение в bucket
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "prj-bucket"
    key        = "terraform.tfstate"

    # get static key_id
    # взял из terraform.tfstate, раздел bucket из adm
    # бэкенд будет работать уже при наличии созданного бакета
    # и выложит туда tfstate
    access_key = "YCAJEQIazPRtyh5DchRVzMgg1"
    secret_key = "YCMTXfoHhHc3v5t5ygby810PacjDtfvZjqRNXYKV"

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