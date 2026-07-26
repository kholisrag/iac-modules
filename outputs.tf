output "cloudflare_turnstile_widget_output" {
  description = "Cloudflare Turnstile Widget Outputs"
  value       = cloudflare_turnstile_widget.widget
  sensitive   = true
}

output "sitekey" {
  description = "Per widget, the public sitekey embedded in the page."
  value = {
    for i, widget in cloudflare_turnstile_widget.widget : i => widget.sitekey
  }
}

output "secret" {
  description = <<-EOT
    Per widget, the secret key used server-side at /siteverify. Sensitive, and
    stored in state — encrypt the state of any stack consuming this module.
  EOT
  sensitive   = true
  value = {
    for i, widget in cloudflare_turnstile_widget.widget : i => widget.secret
  }
}
