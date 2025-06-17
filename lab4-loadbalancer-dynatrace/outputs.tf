output "load_balancer_ip" {
    value = google_compute_global_address.vm_ip_address.address
}

output "mig_group_name" {
    value = google_compute_instance_group_manager.vm_instance_group_manager.name
}