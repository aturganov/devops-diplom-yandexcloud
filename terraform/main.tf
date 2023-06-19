
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

# # Создаем публичуню VM, закидываем ssh-ключи и пользователя
# resource "yandex_compute_instance" "vm_pub_1" {
#   name = "vm-pub-1"
#   # zone = var.yandex_zone
#   allow_stopping_for_update = true
#   resources {
#     cores = 2
#     memory = 2
#   }
#   boot_disk {
#     initialize_params {
#       image_id = "${data.yandex_compute_image.my_image.id}"
#       size     = 20
#     }
#   }
#   network_interface {
#     subnet_id = "${yandex_vpc_subnet.yc_subnet_pub.id}"
#     nat       = true
#   }
#   metadata = {
#     # ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#     user-data = data.template_file.user_template.rendered
#   }

#   connection {
#     type = "ssh"
#     user = var.user
#     private_key = tls_private_key.ssh-key.private_key_openssh
#     host     = self.network_interface.0.nat_ip_address
#   }

#   provisioner "file" {
#     content = tls_private_key.ssh-key.private_key_pem
#     destination = pathexpand(var.private_key_path)
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "chmod 600 /home/locadm/.ssh/id_rsa",
#     ]
#   }  
# }

# # Создаем виртуальку в приватной сети
# resource "yandex_compute_instance" "vm_private_1" {
#   name = "vm-private-1"
#   allow_stopping_for_update = true
#   resources {
#     cores = 2
#     memory = 2
#   }
#   boot_disk {
#     initialize_params {
#       image_id = "${data.yandex_compute_image.my_image.id}"
#       size     = 20
#     }
#   }
#   network_interface {
#     subnet_id = "${yandex_vpc_subnet.yc_subnet_private.id}"
#     nat       = false
#   }
#   metadata = {
#     # ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#     user-data = data.template_file.user_template.rendered
#   }
# }