variable "env" {
  type = string
}

variable "database_version" {
  type = string
  default = "POSTGRES_14"
}

variable "database_tier" {
  type = string
  default = "db-f1-micro"
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "cloudsql_replication_region" {
  type = string
}

variable "network_id" {
  type = string
}
