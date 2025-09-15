output "worker_vm_details" {
  value = [
    for instance in yandex_compute_instance.worker_instances : {
      name            = instance.name,
      ext_ip_address  = instance.network_interface[0].nat_ip_address
      int_ip_address  = instance.network_interface[0].ip_address
    }
  ]
}

output "master_vm_details" {
  value = [
    for instance in yandex_compute_instance.master_instances : {
      name            = instance.name,
      ext_ip_address  = instance.network_interface[0].nat_ip_address
      int_ip_address  = instance.network_interface[0].ip_address
    }
  ]
}

output "nat_vm_details" {
  value = [
    for instance in yandex_compute_instance.nat_instances : {
      name            = instance.name,
      ext_ip_address  = instance.network_interface[0].nat_ip_address
      int_ip_address  = instance.network_interface[0].ip_address
    }
  ]
}

output "load_balancer_details" {
  value = tolist(flatten([
    for listener in yandex_lb_network_load_balancer.web_lb.listener : [
      for spec in listener.external_address_spec : spec.address
    ]
  ]))[0]
}