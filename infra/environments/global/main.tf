resource "google_artifact_registry_repository" "my_repo" {
  location      = local.artifact_region
  repository_id = "moonpay-artifacts"
  format        = "DOCKER"
}
