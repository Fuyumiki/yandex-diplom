resource "yandex_alb_target_group" "web" {
  name = "diplom-web-targets"

  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "web" {
  name = "diplom-web-backends"

  http_backend {
    name             = "nginx"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    healthcheck {
      timeout             = "1s"
      interval            = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "diplom-http-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "diplom-web"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "all"

    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }

      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout          = "10s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name               = "diplom-alb"
  network_id         = yandex_vpc_network.diplom.id
  security_group_ids = [yandex_vpc_security_group.alb.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public_a.id
    }
  }

  listener {
    name = "http"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }

  depends_on = [yandex_alb_virtual_host.web]
}

output "alb_public_ip" {
  value = yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}
