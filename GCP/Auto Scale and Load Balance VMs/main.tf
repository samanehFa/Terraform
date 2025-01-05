provider "google" {
  version = "6.14.1"
  project = var.project
  region = var.region
  zone = var.zone
}

terraform {
  backend "gcs" {
    bucket = "terraformtest11454"
    prefix = "terraform1"
    
   }
}

resource "google_compute_network" "vpc_network"{
  name = "terraform-network"
}

resource "google_compute_autoscaler" "webserver"{
  name = "my-autoscaler"
  project = var.project
  zone = var.zone
  target = google_compute_instance_group_manager.webserver.self_link

  autoscaling_policy{
    max_replicas = 5
    min_replicas = 1
    cooldown_period = 60

    cpu_utilization{
      target = 0.5
    }
  }
}

resource "google_compute_instance_template" "webserver"{
  name = "webserver-instance-template"
  machine_type = "n1-standard-1"
  can_ip_forward = false
  project = var.project
  tags = ["frontend","allow-lb-service"]

  disk{
    source_image = data.google_compute_image.centos-9.self_link
  }
  network_interface {
    network = "default"
  }
  metadata = {
    frontend = "allow-lb-service"
  }
  service_account{
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_target_pool" "webserver" {
  name = "webserver-target-pool"
  project = var.project
  region = var.region
}

resource "google_compute_instance_group_manager" "webserver" {
  name = "webserver-igm"
  zone = var.zone
  project = var.project
  version {
    instance_template = google_compute_instance_template.webserver.self_link
    name = "primary"
  }
  target_pools       = [google_compute_target_pool.webserver.self_link]
  base_instance_name = "terraform"
}

data "google_compute_image" "centos-9" {
  family = "centos-stream-9"
  project = "centos-cloud"
}

module "lb" {
  source = "GoogleCloudPlatform/lb/google"
  version = "2.2.0"
  region = var.region
  name = "load-balancer"
  service_port = 80
  target_tags = ["my-target-pool"]
  network = google_compute_network.vpc_network.name
  
}