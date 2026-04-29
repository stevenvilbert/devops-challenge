variable "env" {
  type = string
}

variable "domain" {
  type    = string
  default = "moonpay.svilbert.app"
}

variable "lb_ip_address" {
  type        = string
  description = "External IP address of the load balancer"
}

variable "postgres_endpoint" {
  type = string
}

variable "postgres_replica_endpoint" {
  type = string
}

variable "is_dr" {
  type    = bool
  default = false
}
