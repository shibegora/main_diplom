resource "yandex_vpc_network" "k8s_cluster_network" {
  name = var.vpc_name
}

resource "yandex_vpc_route_table" "private_route_table" {
  network_id = yandex_vpc_network.k8s_cluster_network.id
  name       = var.private_rt_name

  static_route {
    destination_prefix = var.private_dest_addr_pref
    next_hop_address  = var.nat_vm["nat_vm_1"].ip_address
  }
}

resource "yandex_vpc_subnet" "public_subnet" {
  name           = var.each_subnet["public_subnet"].name
  zone           = var.each_subnet["public_subnet"].zone
  network_id     = yandex_vpc_network.k8s_cluster_network.id
  v4_cidr_blocks = var.each_subnet["public_subnet"].v4_cidr_blocks
}

resource "yandex_vpc_subnet" "private_subnet" {
  name           = var.each_subnet["private_subnet"].name
  zone           = var.each_subnet["private_subnet"].zone
  network_id     = yandex_vpc_network.k8s_cluster_network.id
  v4_cidr_blocks = var.each_subnet["private_subnet"].v4_cidr_blocks
  route_table_id = yandex_vpc_route_table.private_route_table.id
}

locals {
  subnet_map = {
    public  = yandex_vpc_subnet.public_subnet.id
    private = yandex_vpc_subnet.private_subnet.id
  }
  subnet_zone_map = {
    public  = var.each_subnet["public_subnet"].zone
    private = var.each_subnet["private_subnet"].zone
  }
}
locals {
  inventory_content = <<EOT
[kube_control_plane]
%{ for _, worker in var.master_vm ~}
${worker.vm_name} ansible_host=${worker.ip_address}
%{ endfor ~}

[etcd:children]
kube_control_plane

[kube_node]
%{ for _, worker in var.worker_vm ~}
${worker.vm_name} ansible_host=${worker.ip_address}
%{ endfor ~}
EOT
}

resource "yandex_compute_instance" "master_instances" {
  for_each   = var.master_vm
  name       = each.value.vm_name
  hostname   = each.value.vm_name
  platform_id = each.value.platform_id
  zone        = local.subnet_zone_map[each.value.subnet_name]
  allow_stopping_for_update = each.value.allow_stopping

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = each.value.os_family
      type     = each.value.type
      size     = each.value.disk_volume
    }
  }
  scheduling_policy {
    preemptible = each.value.scheduling_policy
  }
  network_interface {
    subnet_id  = local.subnet_map[each.value.subnet_name]
    ip_address = each.value.ip_address
    nat        = each.value.network_interface
  }
  metadata = {
    user-data = templatefile("${path.module}/cloud-init/cloud-init-master.yaml", {
      vms_ssh_root_key  = var.vms_ssh_root_key,
      ssh_private_key   = indent(6, var.master_ssh_private_key),
      inventory_content = indent(6, local.inventory_content)
    })
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "worker_instances" {
  for_each   = var.worker_vm
  name       = each.value.vm_name
  hostname   = each.value.vm_name
  platform_id = each.value.platform_id
  zone        = local.subnet_zone_map[each.value.subnet_name]
  allow_stopping_for_update = each.value.allow_stopping

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = each.value.os_family
      type     = each.value.type
      size     = each.value.disk_volume
    }
  }
  scheduling_policy {
    preemptible = each.value.scheduling_policy
  }
  network_interface {
    subnet_id  = local.subnet_map[each.value.subnet_name]
    ip_address = each.value.ip_address
    nat        = each.value.network_interface
  }
  metadata = {
    user-data = templatefile("${path.module}/cloud-init/cloud-init-worker.yaml", {
      vms_ssh_root_key = var.vms_ssh_root_key
    })
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "nat_instances" {
  for_each   = var.nat_vm
  name       = each.value.vm_name
  hostname   = each.value.vm_name
  platform_id = each.value.platform_id
  zone        = local.subnet_zone_map[each.value.subnet_name]
  allow_stopping_for_update = each.value.allow_stopping

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = each.value.os_family
      type     = each.value.type
      size     = each.value.disk_volume
    }
  }
  scheduling_policy {
    preemptible = each.value.scheduling_policy
  }
  network_interface {
    subnet_id  = local.subnet_map[each.value.subnet_name]
    ip_address = each.value.ip_address
    nat        = each.value.network_interface
  }
  metadata = {
    user-data = templatefile("${path.module}/cloud-init/cloud-init-worker.yaml", {
      vms_ssh_root_key = var.vms_ssh_root_key
    })
    serial-port-enable = 1
  }
}

resource "yandex_lb_target_group" "worker_target_group" {
  name      = var.target_group_name
  region_id = var.default_region

  dynamic "target" {
    for_each = {
      for k, instance in var.worker_vm :
      k => {
        subnet_id = local.subnet_map[instance.subnet_name]
        address   = instance.ip_address
      }
    }
    content {
      subnet_id = target.value.subnet_id
      address   = target.value.address
    }
  }
}

resource "yandex_lb_network_load_balancer" "web_lb" {
  name      = var.load_balancer_config.name
  region_id = var.default_region

  listener {
    name         = var.load_balancer_config.listener_name
    port         = var.load_balancer_config.listener_port
    target_port  = var.load_balancer_config.target_port
    protocol     = var.load_balancer_config.protocol
    external_address_spec {
      ip_version = var.load_balancer_config.ip_version
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.worker_target_group.id
    healthcheck {
      name = var.load_balancer_config.healthcheck_name
      tcp_options {
        port = var.load_balancer_config.healthcheck_port
      }
    }
  }
}