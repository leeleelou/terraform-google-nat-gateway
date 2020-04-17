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

# variable "module_enabled" {
#   description = "To disable this module, set this to false"
#   default     = true
# }

variable "project" {
  description = "The project to deploy to, if not set the default provider project is used."
  default     = ""
}

variable "network" {
  description = "The network to deploy to"
  default     = "default"
}

variable "network_project" {
  description = "Name of the project for the network. Useful for shared VPC. Default is var.project."
  default     = ""
}

variable "subnetwork" {
  description = "The subnetwork to deploy to"
  default     = "default"
}

variable "region" {
  description = "The region to create the nat gateway instance in."
}

variable "zone" {
  description = "Override the zone used in the `region_params` map for the region."
  default     = ""
}

variable "name" {
  description = "Prefix added to the resource names, for example 'prod-'. By default, resources will be named in the form of '<name>nat-gateway-<zone>'"
  default     = ""
}

variable "ip_address_name" {
  description = "Name of an existing reserved external address to use."
  default     = ""
}

variable "tags" {
  description = "Additional compute instance network tags to apply route to."
  type        = list(string)
  default     = []
}

variable "route_priority" {
  description = "The priority for the Compute Engine Route"
  default     = 800
}

variable "machine_type" {
  description = "The machine type for the NAT gateway instance"
  default     = "n1-standard-1"
}

variable "compute_image" {
  description = "Image used for NAT compute VMs."
  default     = "projects/debian-cloud/global/images/family/debian-9"
}

variable "ip" {
  description = "Override the internal IP. If not provided, an internal IP will automatically be assigned."
  default     = ""
}

variable "squid_enabled" {
  description = "Enable squid3 proxy on port 3128."
  default     = "false"
}

variable "squid_config" {
  description = "The squid config file to use. If not specifed the module file config/squid.conf will be used."
  default     = ""
}

variable "metadata" {
  description = "Metadata to be attached to the NAT gateway instance"
  type        = map(string)
  default     = {}
}

variable "ssh_fw_rule" {
  description = "Whether or not the SSH Firewall Rule should be created"
  default     = true
}

variable "ssh_source_ranges" {
  description = "Network ranges to allow SSH from"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_labels" {
  description = "Labels added to instances."
  type        = map(string)
  default     = {}
}

variable "service_account" {
  description = "The email of the service account for the instance template."
  default     = {
    email     = "default"
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/devstorage.full_control",
    ]
  }
}

variable "autohealing_enabled" {
  description = "Enable instance autohealing using http health check"
  default     = false
}

variable "region_params" {
  description = "Map of default zones and IPs for each region. Can be overridden using the `zone` and `ip` variables."
  type        = map(string)

  default = {
  }
}

variable "dest_range" {
  description = "The destination IPv4 address range that this route applies to"
  default     = "0.0.0.0/0"
}

