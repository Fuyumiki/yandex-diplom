locals {
  web_servers = {
    web-1 = {
      zone      = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.private_a.id
    }
    web-2 = {
      zone      = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.private_b.id
    }
  }
}

resource "yandex_compute_instance" "web" {
  for_each = local.web_servers

  name                      = each.key
  hostname                  = each.key
  zone                      = each.value.zone
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
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
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.ssh_internal.id,
      yandex_vpc_security_group.web.id,
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
