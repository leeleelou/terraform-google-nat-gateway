/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


###############
# Data Sources
###############

data "google_compute_address" "default" {
  count   = var.ip_address_name == "" ? 0 : 1
  name    = var.ip_address_name
  project = var.network_project == "" ? var.project : var.network_project
  region  = var.region
}

data "google_compute_instance_group" "default" {
  self_link = module.nat-gateway.instance_group
}

data "google_compute_network" "network" {
  name    = var.network
  project = var.network_project == "" ? var.project : var.network_project
}

#########
# Locals
#########

locals {
  external_ip = try(
    google_compute_address.default.*.address[0],
    data.google_compute_address.default.*.address[0],
  )
  instances     = tolist(data.google_compute_instance_group.default.instances)
  instance_tags = ["inst-${local.zonal_tag}", "inst-${local.regional_tag}"]
  module_path   = path.module
  name          = "${var.name}nat-gateway-${local.zone}"
  regional_tag  = "${var.name}nat-${var.region}"
  zonal_tag     = "${var.name}nat-${local.zone}"
  zone          = var.zone == "" ? var.region_params[var.region]["zone"] : var.zone
}

#########
# Modules
#########

resource "google_compute_address" "default" {
  count   = var.ip_address_name == "" ? 1 : 0
  name    = local.zonal_tag
  project = var.project
  region  = var.region
}

resource "google_compute_route" "nat-gateway" {
  count                  = length(local.instances)
  name                   = local.zonal_tag
  project                = var.project
  dest_range             = var.dest_range
  network                = data.google_compute_network.network.self_link
  next_hop_instance      = local.instances[count.index]
  next_hop_instance_zone = local.zone
  tags                   = compact(concat([local.regional_tag, local.zonal_tag], var.tags))
  priority               = var.route_priority
}

resource "google_compute_firewall" "nat-gateway" {
  name    = local.zonal_tag
  network = var.network
  project = var.project

  source_tags = compact(concat([local.regional_tag, local.zonal_tag], var.tags))
  target_tags = compact(concat(local.instance_tags, var.tags))

  allow {
    protocol = "all"
  }
}

module "nat-gateway" {
  source             = "github.com/automotivemastermind/terraform-google-managed-instance-group?ref=2.0.0"
  name               = local.name
  project            = var.project
  region             = var.region
  zone               = local.zone
  network            = var.network
  subnetwork         = var.subnetwork
  can_ip_forward     = true
  http_health_check  = var.autohealing_enabled
  instance_labels    = var.instance_labels
  metadata           = var.metadata
  network_ip         = var.ip
  target_tags        = local.instance_tags
  machine_type       = var.machine_type
  source_image       = var.compute_image
  target_size        = 1
  service_account    = var.service_account
  service_port       = 80
  service_port_name  = "http"
  ssh_fw_rule        = var.ssh_fw_rule
  ssh_source_ranges  = var.ssh_source_ranges
  wait_for_instances = true
  access_config = [
    {
      nat_ip       = local.external_ip
      network_tier = "PREMIUM"
    }
  ]

  named_ports = [
    {
      name = "http"
      port = 80
    }
  ]

  startup_script = templatefile(
    "${path.module}/config/startup.sh",
    {
      squid_enabled = false,
      squid_config  = "",
      module_path   = path.module
    }
  )

  update_policy = [
    {
      type                  = "PROACTIVE"
      minimal_action        = "REPLACE"
      max_surge_fixed       = 0
      max_unavailable_fixed = 1
      min_ready_sec         = 30
    }
  ]
}
