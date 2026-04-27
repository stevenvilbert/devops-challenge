resource "google_service_account" "default" {
  account_id   = "moonpay-gke-sa"
  display_name = "Service Account for GKE"
}
