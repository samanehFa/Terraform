variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The default GCP region"
  type        = string
}

variable "zone" {
  description = "The default GCP zone"
  type        = string
}

variable "firewall_rules" {
  description = "List of firewall rules to apply"
  type = list(object({
    name          = string
    protocol      = string
    ports         = list(string)
    direction     = string
    source_ranges = list(string)
  }))
}

variable "compute_instances" {
  description = "List of compute instances to create"
  type = list(object({
    name         = string
    machine_type = string
    zone         = string
  }))
}
