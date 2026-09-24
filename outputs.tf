output "instance_public_ip" {
  description = "External IPv4 address of the web server."
  value       = google_compute_instance.webserver.network_interface[0].access_config[0].nat_ip
}

output "instance_image_id" {
  description = "Source image used to initialize the instance boot disk."
  value       = google_compute_instance.webserver.boot_disk[0].initialize_params[0].image
}

output "instance_type" {
  description = "Machine type of the web server."
  value       = google_compute_instance.webserver.machine_type
}

output "instance_network" {
  description = "Self link of the instance VPC network."
  value       = google_compute_instance.webserver.network_interface[0].network
}

output "instance_subnet" {
  description = "Self link of the instance subnetwork."
  value       = google_compute_instance.webserver.network_interface[0].subnetwork
}

output "instance_zone" {
  description = "Zone of the web server."
  value       = google_compute_instance.webserver.zone
}
