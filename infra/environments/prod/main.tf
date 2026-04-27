locals {
  environment = "prod"
  project_id  = "moonpay-playground"
  region      = "us-central1"
}


module "gke" {
  source      = "../../modules/gke"
  env = local.environment
  project_id  = local.project_id
  region      = local.region
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
