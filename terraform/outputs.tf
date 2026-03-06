output "controller_internal_ips" {
  value = google_compute_address.controller_ips[*].address
}

output "worker_internal_ips" {
  value = google_compute_address.worker_ips[*].address
}

output "controller_external_ips" {
  value = google_compute_instance.controllers[*].network_interface[0].access_config[0].nat_ip
}

output "worker_external_ips" {
  value = google_compute_instance.workers[*].network_interface[0].access_config[0].nat_ip
}

output "ssh_instructions" {
  value = <<-EOT
    Connect to nodes using:
    ssh ubuntu@<EXTERNAL_IP>
    
    Internal IPs (for certs):
    Controllers: ${join(", ", google_compute_address.controller_ips[*].address)}
    Workers:     ${join(", ", google_compute_address.worker_ips[*].address)}
  EOT
}