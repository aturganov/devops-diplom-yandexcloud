
# Добавляем сеть по умолчанию. 
resource "yandex_vpc_network" "network" {
  name = "network"
}

# Добавляем stage подсеть
# Зона для stage ставится по дефолту
resource "yandex_vpc_subnet" "subnet_stage" {
  name           = "stage"
  description    = "stage-subnet"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = "${yandex_vpc_network.network.id}"
  zone = "${var.zone-stage}"
}

# Добавляем приватную подсеть 
resource "yandex_vpc_subnet" "subnet_prod" {
  name           = "prod"
  description    = "prod-subnet"
  v4_cidr_blocks = ["192.168.20.0/24"]
  network_id     = "${yandex_vpc_network.network.id}"
  zone = "${var.zone-prod}"
#   route_table_id = yandex_vpc_route_table.yc_route_table_private.id
}

# Подсеть обслуживающих сервисов
resource "yandex_vpc_subnet" "subnet_manage"   {
  name = "manage"
  description    = "manage-subnet"
  v4_cidr_blocks = ["192.168.30.0/24"]
  network_id     = "${yandex_vpc_network.network.id}"
  zone = "${var.zone-manage}"
}