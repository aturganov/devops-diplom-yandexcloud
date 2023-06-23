
resource "yandex_iam_service_account" "sa" {
  folder_id   = var.folder_id
  description = "Service account for terraform"
  name        = "sa"
}

# В случае role = "storage.editor" выдает ошибку access denied
resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
  folder_id = var.folder_id
  #role      = "storage.admin"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "keys" {
  service_account_id = yandex_iam_service_account.sa.id
  # service_account_id = var.service_account
  description        = "Access keys for object storage"
}

resource "yandex_storage_bucket" "storage_bucket" {
  bucket     = "prj-bucket"
  # access_key = "YCAJETZLWjSNf6hs1WgRkaJzh"
  # secret_key = "YCNKYCL3CasVy3xpkImKm0IxiGxdzsX3fyD7Ddmr"
  access_key = yandex_iam_service_account_static_access_key.keys.access_key
  secret_key = yandex_iam_service_account_static_access_key.keys.secret_key
  # region     = "ru-central1"

  lifecycle_rule {
    prefix  = "config/"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      
      storage_class = "COLD"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }
}

# Ссылки
# https://sidmid.ru/%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%D1%82%D1%8C-%D1%81-terraform-%D0%B2-yandex-%D0%BE%D0%B1%D0%BB%D0%B0%D0%BA%D0%B5/
# https://github.com/yandex-cloud/terraform-provider-yandex/issues/261

# Команды:
# Включаем логирование
# export TF_LOG="DEBUG"

#default 
# export TF_LOG="TRACE"  

# terraform init -migrate-state
# terraform init -upgrade

# yc iam service-account list

# yc iam service-account create --name sa --description "Service account"

# Пример роли: 
# yc resource-manager folder add-access-binding b1gkgthf18fqkuii66ht \
# >   --role storage.editor \
# >   --subject serviceAccount:ajemvk0147sfeojfoh3m
# yc iam access-key create --service-account-name sa