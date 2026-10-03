resource "yandex_vpc_security_group" "kibana" {
  ingress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["195.234.63.52/32"]
  }

  name       = "diplom-kibana"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = [var.admin_cidr]
  }
}

resource "yandex_vpc_security_group" "elasticsearch" {
  name       = "diplom-elasticsearch"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.web.id
  }

  ingress {
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana.id
  }

  ingress {
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.bastion.id
  }
}

locals {
  logging_servers = {
    elasticsearch = {
      memory    = 4
      subnet_id = yandex_vpc_subnet.private_a.id
      nat       = false
      group_id  = yandex_vpc_security_group.elasticsearch.id
    }
    kibana = {
      memory    = 2
      subnet_id = yandex_vpc_subnet.public_a.id
      nat       = true
      group_id  = yandex_vpc_security_group.kibana.id
    }
  }
}

resource "yandex_compute_instance" "logging" {
  for_each = local.logging_servers

  name                      = each.key
  hostname                  = each.key
  zone                      = "ru-central1-a"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    core_fraction = 20
    memory        = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = each.value.subnet_id
    nat       = each.value.nat
    security_group_ids = [
      each.value.group_id,
      yandex_vpc_security_group.ssh_internal.id,
      yandex_vpc_security_group.vm_egress.id
    ]
  }

  scheduling_policy {
    preemptible = false
  }

  metadata = {
    user-data = "#cloud-config\n${yamlencode({
      users = [{
        name        = "ubuntu"
        groups      = "sudo"
        shell       = "/bin/bash"
        sudo        = "ALL=(ALL) NOPASSWD:ALL"
        lock_passwd = true
        ssh_authorized_keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHWfh/k/n0ZkkuAU+biDH/sla+YJ36H/pGgOQBNK88EJ",
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1OzNHCkwtg4KQEUQSiVdmAHgpX1zybOkFLzyxPXqlB ansible@bastion"
        ]
      }]
      ssh_pwauth = false
    })}"
  }
}

output "kibana_public_ip" {
  value = yandex_compute_instance.logging["kibana"].network_interface[0].nat_ip_address
}

output "elasticsearch_private_ip" {
  value = yandex_compute_instance.logging["elasticsearch"].network_interface[0].ip_address
}
