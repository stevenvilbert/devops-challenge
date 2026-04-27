locals {
  environment = "prod"
  project_id  = "moonpay-playground"
  region      = "us-central1"
  gke_node_count = 2
}


module "gke" {
  depends_on = [ module.iam ]
  source      = "../../modules/gke"
  env = local.environment
  project_id  = local.project_id
  region      = local.region
  service_account_email = module.iam.service_account_email
  node_count = local.gke_node_count
}

# module "cloudsql" {
#   source      = "../../modules/cloudsql"
#   env = local.environment
#   project_id  = local.project_id
#   region      = local.region
# }

module "iam" {
  source      = "../../modules/iam"
  env = local.environment
  project_id  = local.project_id
}

# module "secrets" {
#   source      = "../../modules/secrets"
#   environment = local.environment
#   project_id  = local.project_id
# }
