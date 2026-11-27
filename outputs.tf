output "cloudflare_zero_trust_access_application_output" {
  description = <<-EOT
    Cloudflare Zero Trust Access Application Outputs.

    Every attribute the provider exposes EXCEPT the deprecated ones named
    below, because an output that derives from a deprecated attribute makes
    OpenTofu warn on every `plan` in every consuming stack — noise the consumer
    can neither fix nor silence.

    The exclusion list is written out; the attribute set is not. A new provider
    attribute therefore appears here on its own, and only a NEW upstream
    deprecation brings the warning back — which is the right signal, since
    somebody then has to decide whether consumers still need that attribute.
    Adding it to the list is the acknowledgement.

    `self_hosted_domains` is superseded by `destinations`, which this module
    already sets.
  EOT
  value = {
    for i, app in cloudflare_zero_trust_access_application.application : i => {
      for k, v in app : k => v
      if !contains(["self_hosted_domains"], k)
    }
  }
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
