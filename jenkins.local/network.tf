# Добавляем сеть по умолчанию. 
resource "yandex_vpc_network" "network-jenkins" {
  name = "network_jenkins"
}

# Добавляем stage подсеть
# Зона для stage ставится по дефолту
resource "yandex_vpc_subnet" "subnet_jenkins" {
  name           = "jenkins"
  description    = "jenkins-subnet"
  v4_cidr_blocks = ["192.168.30.0/24"]
  network_id     = "${yandex_vpc_network.network-jenkins.id}"
  zone = "${var.zone-stage}"
}