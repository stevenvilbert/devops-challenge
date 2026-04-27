variable "node_count" {
  type = number
  default = 1
}

variable "env" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}


variable "service_account_email" {
  type = string
}

variable "gke_disk_space" {
  type    = number
  default = 30

  validation {
    condition     = var.gke_disk_space <= 30
    error_message = "Disk size must not exceed 30 GB for the default node pool."
  }
}
