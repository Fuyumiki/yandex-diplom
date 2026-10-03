resource "yandex_vpc_security_group" "zabbix" {
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["195.234.63.52/32"]
  }

  ingress {
    description    = "Temporary mobile network diagnostic access"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["193.233.19.224/32"]
  }
  name       = "diplom-zabbix"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [var.admin_cidr]
  }

  ingress {
    protocol          = "TCP"
    port              = 10051
    security_group_id = yandex_vpc_security_group.vm_egress.id
  }
}

resource "yandex_compute_instance" "zabbix" {
  name                      = "zabbix"
  hostname                  = "zabbix"
  zone                      = "ru-central1-a"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_a.id
    nat       = true

    security_group_ids = [
      yandex_vpc_security_group.zabbix.id,
      yandex_vpc_security_group.ssh_internal.id,
      yandex_vpc_security_group.vm_egress.id
    ]
  }

  scheduling_policy {
    preemptible = false
  }

  metadata = {
    ssh-keys = <<-KEYS
ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHWfh/k/n0ZkkuAU+biDH/sla+YJ36H/pGgOQBNK88EJ
ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1OzNHCkwtg4KQEUQSiVdmAHgpX1zybOkFLzyxPXqlB ansible@bastion
KEYS
  }
}

output "zabbix_public_ip" {
  value = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
}
