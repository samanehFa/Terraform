project = "playground-s-11-7087e284"
region  = "us-central1"
zone    = "us-central1-a"

firewall_rules = [
  {
    name          = "allow-icmp"
    protocol      = "icmp"
    ports         = []
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
  },
  {
    name          = "allow-rdp"
    protocol      = "tcp"
    ports         = ["3389"]
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
  },
  {
    name          = "allow-ssh"
    protocol      = "tcp"
    ports         = ["22"]
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
  },
  {
    name          = "allow-custom"
    protocol      = "all"
    ports         = []
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
  }
]

compute_instances = [
  {
    name         = "mynet-us-vm"
    machine_type = "f1-micro"
    zone         = "us-central1-c"
  },
  {
    name         = "mynet-eu-vm"
    machine_type = "f1-micro"
    zone         = "europe-west1-c"
  }
]
