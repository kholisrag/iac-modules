output "cloudflare_zero_trust_device_managed_networks_output" {
  description = <<-EOT
    Cloudflare Zero Trust Device Managed Network Outputs. Carries the endpoint
    address and fingerprint — treat it as topology.
  EOT
  value       = cloudflare_zero_trust_device_managed_networks.managed_network
}

output "managed_network_names" {
  description = <<-EOT
    Per key, the network name a device profile matches with
    `network == "<name>"`. Reference this rather than retyping the string, so a
    rename cannot leave a profile matching a network that no longer exists —
    which fails open to the default profile, silently.
  EOT
  value = {
    for i, network in cloudflare_zero_trust_device_managed_networks.managed_network : i => network.name
  }
}
