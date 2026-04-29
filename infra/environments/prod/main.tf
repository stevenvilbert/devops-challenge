locals {
  environment        = "prod"
  project_id         = "moonpay-playground"
  region             = "us-central1"
  replication_region = "us-east1"
  dr_region          = "us-east1"
  gke_node_count     = 1
  gke_disk_space     = 20
  is_dr              = false
}


module "networking" {
  source     = "../../modules/networking"
  env        = local.environment
  project_id = local.project_id
  region     = local.region
  dr_region = local.dr_region
}

module "dns" {
  source                    = "../../modules/dns"
  env                       = local.environment
  domain                    = "moonpay.svilbert.app"
  lb_ip_address             = module.networking.lb_ip_address
  postgres_endpoint         = module.cloudsql.postgres_endpoint
  postgres_replica_endpoint = module.cloudsql.postgres_replica_endpoint
  is_dr                     = local.is_dr
}

module "gke" {
  depends_on            = [module.iam]
  source                = "../../modules/gke"
  env                   = local.environment
  project_id            = local.project_id
  region                = local.region
  network               = module.networking.network_name
  subnetwork            = module.networking.subnetwork_name
  service_account_email = module.iam.service_account_email
  node_count            = local.gke_node_count
  gke_disk_space        = local.gke_disk_space
}

module "gke_dr" {
  depends_on            = [module.iam]
  source                = "../../modules/gke"
  env                   = "dr-${local.environment}"
  project_id            = local.project_id
  region                = local.dr_region
  network               = module.networking.network_name
  subnetwork            = module.networking.dr_subnetwork_name
  service_account_email = module.iam.service_account_email
  node_count            = local.gke_node_count
  gke_disk_space        = local.gke_disk_space
  enable_node_pool      = local.is_dr
  network_tag           = "gke-moonpay-dr-${local.environment}"
}

module "cloudsql" {
  depends_on                  = [module.networking.service_networking_connection]
  source                      = "../../modules/cloudsql"
  env                         = local.environment
  project_id                  = local.project_id
  region                      = local.region
  cloudsql_replication_region = local.replication_region
  network_id                  = module.networking.network_id
}

module "iam" {
  source     = "../../modules/iam"
  env        = local.environment
  project_id = local.project_id
}

# module "secrets" {
#   source      = "../../modules/secrets"
#   environment = local.environment
#   project_id  = local.project_id
# }
