output "cloudflare_zero_trust_access_application_output" {
  description = "Cloudflare Zero Trust Access Application Outputs"
  value       = cloudflare_zero_trust_access_application.application
}

output "application_aud" {
  description = <<-EOT
    Per application, its Audience (AUD) tag. Needed to make a tunnel ingress
    rule enforce Access via `origin_request.access.aud_tag`, and to verify the
    Cf-Access-Jwt-Assertion header at an origin.
  EOT
  value = {
    for i, app in cloudflare_zero_trust_access_application.application : i => app.aud
  }
}
