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
