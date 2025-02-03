provider "google" {
  version = "6.14.1"
  project = var.project
  region = var.region
  zone = var.zone
}

terraform {
  backend "gcs" {
    bucket = "terraform13333"
    prefix = "terraform1"
    
   }
}

resource "google_compute_network" "vpc_network" {
  project                 = var.project
  name                    = "mynetwork"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "firewall_rules"{
  for_each = { for rule in var.firewall_rules : rule.name => rule }
  name = each.value.name
  network = google_compute_network.vpc_network.name
  project = var.project

  dynamic "allow" {
    for_each = length(each.value.ports)> 0 ? each.value.ports : [null]
    content {
      protocol = each.value.protocol
      ports = each.value.ports
    }
  }
  source_ranges = each.value.source_ranges
}


resource "google_compute_instance" "vm_instances" {
  for_each = { for vm in var.compute_instances : vm.name => vm }
  name = each.value.name
  project = var.project
  zone = each.value.zone
  machine_type = each.value.machine_type

  boot_disk {
    initialize_params{
      image = "projects/debian-cloud/global/images/family/debian-11"
    }
    }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
  metadata = {
    ssh-keys = "debian:${file("~/.ssh/id_rsa.pub")}"
  }
}


resource "null_resource" "ping_test" {
  depends_on = [google_compute_instance.vm_instances]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "debian"
      private_key = file("~/.ssh/id_rsa")
      host        = google_compute_instance.vm_instances["mynet-us-vm"].network_interface[0].access_config[0].nat_ip
    }

    inline = [
      "echo 'Pinging mynet-eu-vm internal IP address...'",
      "ping -c 3 ${google_compute_instance.vm_instances["mynet-eu-vm"].network_interface[0].network_ip}",

      "echo 'Pinging mynet-eu-vm external IP address...'",
      "ping -c 3 ${google_compute_instance.vm_instances["mynet-eu-vm"].network_interface[0].access_config[0].nat_ip}"
    ]
  }

  triggers = {
    always_run = timestamp()
  }
}

