terraform {
  required_version = ">= 1.5, < 2.0"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.140, < 1.0"
    }
  }
}
provider "yandex" {
  zone = "ru-central1-a"
}
