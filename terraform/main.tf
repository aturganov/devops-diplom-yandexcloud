
data "yandex_compute_image" "my_image" {
  family = "ubuntu-2004-lts"
}

# Генерируем приватный ключ
resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Закидываем приватный ключ в текущую папку локально машины
resource "local_sensitive_file" "id_rsa" {
  filename = "ssh_key"
  file_permission = "600"
  content = tls_private_key.ssh-key.private_key_pem
}

# Подключаем шаблон пользователя, прикрепил в проект
data "template_file" "user_template" {
  template = file("user_template.tpl")
  vars = {
    user    = var.user
    ssh_key = tls_private_key.ssh-key.public_key_openssh
  }
}