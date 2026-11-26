output "cloudflare_zero_trust_tunnel_cloudflared_virtual_network_output" {
  description = "Cloudflare Zero Trust Tunnel Virtual Network Outputs"
  value       = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.virtual_network
}

output "cloudflare_zero_trust_tunnel_cloudflared_route_output" {
  description = <<-EOT
    Cloudflare Zero Trust Tunnel Route Outputs. Carries each route's CIDR —
    treat it as topology, and keep it out of anything that publishes outputs.
  EOT
  value       = cloudflare_zero_trust_tunnel_cloudflared_route.route
}

output "virtual_network_ids" {
  description = "Per virtual network key, its ID — what a device profile's `virtual_networks` block or a Gateway policy references."
  value = {
    for i, vnet in cloudflare_zero_trust_tunnel_cloudflared_virtual_network.virtual_network : i => vnet.id
  }
}
