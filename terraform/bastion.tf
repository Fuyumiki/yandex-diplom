data "yandex_compute_image" "ubuntu" {
  image_id = "fd8c21mmbvs6qkc3mnos"
}

resource "yandex_compute_instance" "bastion" {
  name                      = "bastion"
  hostname                  = "bastion"
  zone                      = "ru-central1-a"
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
    subnet_id = yandex_vpc_subnet.public_a.id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.bastion.id,
      yandex_vpc_security_group.vm_egress.id
    ]
  }

  scheduling_policy {
    preemptible = false
  }

  metadata = {
    ssh-keys = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHWfh/k/n0ZkkuAU+biDH/sla+YJ36H/pGgOQBNK88EJ"
  }
}

output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}
