output "cloudflare_zero_trust_tunnel_cloudflared_output" {
  description = <<-EOT
    Cloudflare Zero Trust Tunnel Outputs. Sensitive in whole — the resource
    carries `tunnel_secret`, which the provider marks sensitive, so a root
    module consuming this output cannot re-export it unmarked. Read
    `tunnel_cname` instead when all you need is the CNAME target.
  EOT
  value       = cloudflare_zero_trust_tunnel_cloudflared.tunnel
  sensitive   = true
}

output "cloudflare_zero_trust_tunnel_cloudflared_config_output" {
  description = "Cloudflare Zero Trust Tunnel Config Outputs"
  value       = cloudflare_zero_trust_tunnel_cloudflared_config.config
}

output "tunnel_cname" {
  description = <<-EOT
    Per tunnel, the CNAME target a DNS record must point at to route a hostname
    through it: `<tunnel-id>.cfargotunnel.com`. Creating an ingress rule alone
    routes nothing — the DNS record is the other half.
  EOT
  value = {
    for i, tunnel in cloudflare_zero_trust_tunnel_cloudflared.tunnel :
    i => format("%s.cfargotunnel.com", tunnel.id)
  }
}

output "tunnel_token" {
  description = <<-EOT
    Per tunnel, the connector token `cloudflared` runs with:
    `cloudflared tunnel run --token <token>`. Sensitive — it is full authority
    to serve traffic for that tunnel.
  EOT
  sensitive   = true
  value = {
    for i, token in data.cloudflare_zero_trust_tunnel_cloudflared_token.token :
    i => token.token
  }
}
