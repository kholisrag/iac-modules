output "cloudflare_zero_trust_tunnel_cloudflared_output" {
  description = <<-EOT
    Cloudflare Zero Trust Tunnel Outputs. Sensitive in whole — the resource
    carries `tunnel_secret`, which the provider marks sensitive, so a root
    module consuming this output cannot re-export it unmarked. Read
    `tunnel_cname` instead when all you need is the CNAME target.
    Every attribute the provider exposes EXCEPT the deprecated ones named
    below, because an output that derives from a deprecated attribute makes
    OpenTofu warn on every `plan` in every consuming stack — noise the consumer
    can neither fix nor silence.

    The exclusion list is written out; the attribute set is not. A new provider
    attribute therefore appears here on its own, and only a NEW upstream
    deprecation brings the warning back — which is the right signal, since
    somebody then has to decide whether consumers still need that attribute.
    Adding it to the list is the acknowledgement.

    `connections` is documented as about to start returning an empty array, and
    `remote_config` is superseded by `config_src`.
  EOT
  sensitive   = true
  value = {
    for i, tunnel in cloudflare_zero_trust_tunnel_cloudflared.tunnel : i => {
      for k, v in tunnel : k => v
      if !contains(["connections", "remote_config"], k)
    }
  }
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
