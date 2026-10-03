variable "admin_cidr" {
  description = "Public IPv4 of administrator with /32"
  type = string
  validation {
    condition = can(cidrnetmask(var.admin_cidr)) && endswith(var.admin_cidr, "/32")
    error_message = "Specify a valid IPv4 address with /32."
  }
}
