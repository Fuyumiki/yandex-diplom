resource "yandex_vpc_security_group" "vm_egress" {
  name       = "diplom-vm-egress"
  network_id = yandex_vpc_network.diplom.id

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "bastion" {
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["195.234.63.52/32"]
  }

  ingress {
    description    = "Temporary mobile network diagnostic access"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["193.233.19.224/32"]
  }
  name       = "diplom-bastion"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.admin_cidr]
  }
}

resource "yandex_vpc_security_group" "ssh_internal" {
  name       = "diplom-ssh-internal"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }
}
