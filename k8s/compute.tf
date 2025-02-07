# Instances stage
# 3 машины на убунте

# Создаем публичуню VM, закидываем ssh-ключи и пользователя
resource "yandex_compute_instance" "vm_stage_master" {
  name = "vm-stage-master"
  hostname = "stage-master"
  allow_stopping_for_update = true

  platform_id = "standard-v1"
  # Похоже зона vpc должна совпадать с зоной сети
  zone        = "ru-central1-b"

  resources {
    cores = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.my_image.id}"
      size     = 40
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet_stage.id}"
    nat       = true
  }
  metadata = {
    # ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = data.template_file.user_template.rendered
  }

  connection {
    type = "ssh"
    user = var.user
    private_key = tls_private_key.ssh-key.private_key_openssh
    host     = self.network_interface.0.nat_ip_address
    # host     = self.network_interface.0.ip_address
  }

  provisioner "file" {
    content = tls_private_key.ssh-key.private_key_pem
    destination = pathexpand(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/locadm/.ssh/id_rsa",
    ]
  }  
}

# Создаем VM, закидываем ssh-ключи и пользователя
resource "yandex_compute_instance" "vm_stage_workers" {
  count = 2
  name = "vm-stage-worker-${count.index}"
  hostname = "stage-worker-${count.index}"

  allow_stopping_for_update = true

  platform_id = "standard-v1"
  # Похоже зона vpc должна совпадать с зоной сети
  zone        = "ru-central1-b"

  resources {
    cores = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.my_image.id}"
      size     = 30
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet_stage.id}"
    nat       = true
  }
  metadata = {
    # ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = data.template_file.user_template.rendered
  }

  connection {
    type = "ssh"
    user = var.user
    private_key = tls_private_key.ssh-key.private_key_openssh
    host = self.network_interface.0.nat_ip_address
  }

  provisioner "file" {
    content = tls_private_key.ssh-key.private_key_pem
    destination = pathexpand(var.private_key_path)
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/locadm/.ssh/id_rsa",
    ]
  }  
}


# Prod
# resource "yandex_compute_instance" "vm_prod_master" {
#   name = "vm-prod-master"
#   allow_stopping_for_update = true
#   resources {
#     cores = 2
#     memory = 4
#   }
#   boot_disk {
#     initialize_params {
#       image_id = "${data.yandex_compute_image.my_image.id}"
#       size     = 20
#     }
#   }
#   network_interface {
#     subnet_id = "${yandex_vpc_subnet.subnet_prod.id}"
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

# # Создаем публичуню VM, закидываем ssh-ключи и пользователя
# resource "yandex_compute_instance" "vm_prod_workers" {
#   count = 2
#   name = "vm-stage-workers-${count.index}"
#   allow_stopping_for_update = true
#   resources {
#     cores = 2
#     memory = 2
#   }
#   boot_disk {
#     initialize_params {
#       image_id = "${data.yandex_compute_image.my_image.id}"
#       size     = 10
#     }
#   }
#   network_interface {
#     subnet_id = "${yandex_vpc_subnet.subnet_prod.id}"
#     # nat       = true
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

