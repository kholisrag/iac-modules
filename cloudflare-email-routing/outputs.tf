output "cloudflare_email_routing_address_output" {
  description = "Cloudflare Email Routing Destination Address Outputs"
  value       = cloudflare_email_routing_address.address
}

output "cloudflare_email_routing_settings_output" {
  description = "Cloudflare Email Routing Settings Outputs"
  value       = cloudflare_email_routing_settings.settings
}

output "cloudflare_email_routing_rule_output" {
  description = "Cloudflare Email Routing Rule Outputs"
  value       = cloudflare_email_routing_rule.rule
}

output "unverified_addresses" {
  description = <<-EOT
    Destination addresses that have not been verified yet. A forward rule
    pointing at one of these drops mail without erroring, so this is the list to
    check after an apply.
  EOT
  value = [
    for address in cloudflare_email_routing_address.address :
    address.email if address.verified == null
  ]
}
