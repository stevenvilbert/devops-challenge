resource "google_container_cluster" "primary" {
  name       = "moonpay-gke-cluster-${var.env}"
  location   = var.region
  network    = var.network
  subnetwork = var.subnetwork

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  cluster_autoscaling {

  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name     = "moonpay-gke-${var.env}-np"
  location = var.region
  cluster  = google_container_cluster.primary.name

  #this defines default node count, autoscaling config will apply after deploy
  node_count = var.node_count


  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = var.gke_disk_space
    tags         = ["gke-moonpay-${var.env}"]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = var.service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  lifecycle {
    ignore_changes = [
      node_count,
      node_config[0].resource_labels,
    ]
  }
}
