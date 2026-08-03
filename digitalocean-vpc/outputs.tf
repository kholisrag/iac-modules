output "digitalocean_vpc_output" {
  description = "DigitalOcean VPC outputs, keyed by the input map's key."
  value       = digitalocean_vpc.vpc
}

output "digitalocean_vpc_ids" {
  description = <<-EOT
    VPC UUID by input map key. This is what a `digitalocean_database_cluster`,
    Droplet or load balancer wants as `private_network_uuid` / `vpc_uuid`, and
    reading it from here rather than from the whole-object output keeps a
    consumer's dependency on one scalar.
  EOT
  value       = { for k, v in digitalocean_vpc.vpc : k => v.id }
}

output "digitalocean_vpc_urns" {
  description = "VPC URN by input map key, for project resource assignment."
  value       = { for k, v in digitalocean_vpc.vpc : k => v.urn }
}
