resource "yandex_compute_snapshot_schedule" "daily" {
  name             = "diplom-daily"
  description      = "Daily snapshots of all six VM disks, retained for 7 days"
  retention_period = "168h0m0s"

  schedule_policy {
    expression = "0 19 * * *"
  }

  snapshot_spec {
    description = "Diplom scheduled disk backup"
    labels = {
      project = "diplom"
    }
  }

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.web["web-1"].boot_disk[0].disk_id,
    yandex_compute_instance.web["web-2"].boot_disk[0].disk_id,
    yandex_compute_instance.zabbix.boot_disk[0].disk_id,
    yandex_compute_instance.logging["elasticsearch"].boot_disk[0].disk_id,
    yandex_compute_instance.logging["kibana"].boot_disk[0].disk_id
  ]
}
