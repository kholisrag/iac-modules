output "cloudflare_zero_trust_access_service_token_output" {
  description = "Cloudflare Zero Trust Access Service Token Outputs. Sensitive in whole — it carries `client_secret`."
  value       = cloudflare_zero_trust_access_service_token.service_token
  sensitive   = true
}

output "token_ids" {
  description = <<-EOT
    Per token, its ID. This is what a Service Auth policy references as
    `include = [{ service_token = { token_id = ... } }]` — not the client ID.
  EOT
  value = {
    for i, token in cloudflare_zero_trust_access_service_token.service_token : i => token.id
  }
}

output "client_ids" {
  description = <<-EOT
    Per token, the Client ID sent in the `CF-Access-Client-Id` request header.
    Not a secret on its own; useless without the matching client secret.
  EOT
  value = {
    for i, token in cloudflare_zero_trust_access_service_token.service_token : i => token.client_id
  }
}

output "client_secrets" {
  description = <<-EOT
    Per token, the Client Secret sent in the `CF-Access-Client-Secret` request
    header. Sensitive, and stored in state — encrypt the state of any stack
    consuming this module. Cloudflare does not show it again after creation, so
    state is the only copy.
  EOT
  sensitive   = true
  value = {
    for i, token in cloudflare_zero_trust_access_service_token.service_token : i => token.client_secret
  }
}

output "expires_at" {
  description = <<-EOT
    Per token, when it stops authenticating, derived from `duration` at
    creation. Nothing renews it for you — expiry is a scheduled outage unless
    someone rotates first.
  EOT
  value = {
    for i, token in cloudflare_zero_trust_access_service_token.service_token : i => token.expires_at
  }
}
