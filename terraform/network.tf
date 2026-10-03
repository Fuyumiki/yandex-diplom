resource "yandex_vpc_network" "diplom" {
  name = "diplom-network"
}

resource "yandex_vpc_gateway" "nat" {
  name = "diplom-nat"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "diplom-private-route"
  network_id = yandex_vpc_network.diplom.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "public_a" {
  name           = "diplom-public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

resource "yandex_vpc_subnet" "private_a" {
  name           = "diplom-private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["10.10.10.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_subnet" "private_b" {
  name           = "diplom-private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["10.10.20.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}
