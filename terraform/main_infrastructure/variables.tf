variable "metadata" {
  type                = map(string)
  default             = {}
}
variable "cloud_id" {
  type                = string
}
variable "folder_id" {
  type                = string
}
variable "sa_key_file" {
  default             = "key.json"
  description         = "Path to the service account JSON key"
}
variable "default_zone" {
  type                = string
  default             = "ru-central1-a"
}
variable "default_region" {
  type                = string
  default             = "ru-central1"
}
variable "vpc_name" {
  type                = string
  default             = "k8s-cluster-vps"
  description         = "VPC name"
}
variable "private_dest_addr_pref" {
  type                = string
  default             = "0.0.0.0/0"
  description         = "route-table dest addr"
}
variable "private_rt_name" {
  type                = string
  default             = "private-route-table"
  description         = "route-table name"
}
variable "vms_ssh_root_key" {
  type                = string
  description         = "SSH public key for VM access"
}
variable "master_ssh_private_key" {
  description         = "Private SSH-key for master-node"
  type                = string
  sensitive           = true
}
variable "target_group_name" {
  default             = "target-group"
  description         = "target-group name"
}
variable "each_subnet" {
  type = map(object({
    name              =string
    zone              =string
    v4_cidr_blocks    =list(string)
  }))
  default = {
    "public_subnet" = {
      name            = "public"
      zone            = "ru-central1-a"
      v4_cidr_blocks  = ["192.168.0.0/24"]
    }
    "private_subnet" = {
      name            = "private"
      zone            = "ru-central1-b"
      v4_cidr_blocks  = ["192.168.10.0/24"]
    }
  }
}
variable "worker_vm" {
  type = map(object({
    platform_id         = string
    vm_name             = string
    cpu                 = number
    ram                 = number
    core_fraction       = number
    type                = string
    disk_volume         = number
    network_interface   = bool
    scheduling_policy   = bool
    os_family           = string
    subnet_name         = string
    ip_address          = string
    allow_stopping      = bool
    }))
  default = {
    "vm1" = {
      platform_id       = "standard-v3"
      vm_name           = "worker-node1"
      cpu               = 2
      ram               = 4
      core_fraction     = 20
      type              = "network-hdd"
      disk_volume       = 50
      network_interface = false
      scheduling_policy = true
      os_family         = "fd8jnll1ou4fv2gil3rv"
      subnet_name       = "private"
      ip_address        = "192.168.10.10"
      allow_stopping    = true
    }
    "vm2" = {
      platform_id       = "standard-v3"
      vm_name           = "worker-node2"
      cpu               = 2
      ram               = 4
      core_fraction     = 20
      type              = "network-hdd"
      disk_volume       = 50
      network_interface = false
      scheduling_policy = true
      os_family         = "fd8jnll1ou4fv2gil3rv"
      subnet_name       = "private"
      ip_address        = "192.168.10.20"
      allow_stopping    = true
    }
    "vm3" = {
      platform_id       = "standard-v3"
      vm_name           = "worker-node3"
      cpu               = 2
      ram               = 4
      core_fraction     = 20
      type              = "network-hdd"
      disk_volume       = 50
      network_interface = false
      scheduling_policy = true
      os_family         = "fd8jnll1ou4fv2gil3rv"
      subnet_name       = "private"
      ip_address        = "192.168.10.30"
      allow_stopping    = true
    }
  }
}
variable "master_vm" {
  type = map(object({
    platform_id         = string
    vm_name             = string
    cpu                 = number
    ram                 = number
    core_fraction       = number
    type                = string
    disk_volume         = number
    network_interface   = bool
    scheduling_policy   = bool
    os_family           = string
    subnet_name         = string
    ip_address          = string
    allow_stopping      = bool
    }))
  default = {
    "master_node_1" = {
      platform_id       = "standard-v3"
      vm_name           = "master-node1"
      cpu               = 2
      ram               = 4
      core_fraction     = 20
      type              = "network-hdd"
      disk_volume       = 50
      network_interface = true
      scheduling_policy = true
      os_family         = "fd8jnll1ou4fv2gil3rv"
      subnet_name       = "public"
      ip_address        = "192.168.0.250"
      allow_stopping    = false
    }
  }
}
variable "nat_vm" {
  type = map(object({
    platform_id         = string
    vm_name             = string
    cpu                 = number
    ram                 = number
    core_fraction       = number
    type                = string
    disk_volume         = number
    network_interface   = bool
    scheduling_policy   = bool
    os_family           = string
    subnet_name         = string
    ip_address          = string
    allow_stopping      = bool
    }))
  default = {
    "nat_vm_1" = {
      platform_id       = "standard-v3"
      vm_name           = "nat-instance"
      cpu               = 2
      ram               = 2
      core_fraction     = 20
      type              = "network-hdd"
      disk_volume       = 10
      network_interface = true
      scheduling_policy = true
      os_family         = "fd80mrhj8fl2oe87o4e1"
      subnet_name       = "public"
      ip_address        = "192.168.0.254"
      allow_stopping    = true
    }
  }
}
variable "load_balancer_config" {
  description           = "load-balancer variables"
  type = object({
    name                = string
    target_group_name   = string
    listener_name       = string
    listener_port       = number
    target_port         = number
    healthcheck_port    = number
    protocol            = string
    ip_version          = string
    healthcheck_name    = string
  })
  default = {
    name                = "web-balance"
    target_group_name   = "my-target-group"
    listener_name       = "http-listener"
    listener_port       = 80
    target_port         = 30080
    healthcheck_port    = 22
    protocol            = "tcp"
    ip_version          = "ipv4"
    healthcheck_name    = "http-healthcheck"
  }
}