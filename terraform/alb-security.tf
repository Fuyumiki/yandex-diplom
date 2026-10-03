resource "yandex_vpc_security_group" "alb" {
  name       = "diplom-alb"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    port              = 30080
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "diplom-web"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb.id
  }
}
