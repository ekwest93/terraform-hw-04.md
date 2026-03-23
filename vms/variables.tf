variable "public_key" {
  type        = string
  description = "SSH public key for VM access"
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiVcfW8Wa/DxbBNzmQcwn7hJOj7ji9eoTpFakVnY/AI webinar"
}

variable "vms_list" {
  type        = list(string)
  description = "List of VM names for password generation"
  default     = ["web-1", "web-2", "db-1"]
}
