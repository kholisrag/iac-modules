locals {
  applications = {
    for i, app in var.applications : i => merge(
      {
        name       = i
        account_id = var.account_id
      },
      app
    )
  }
}

resource "cloudflare_zero_trust_access_application" "application" {
  for_each = local.applications

  account_id = lookup(each.value, "account_id", null)
  zone_id    = lookup(each.value, "zone_id", null)

  name = each.value.name
  type = lookup(each.value, "type", null)

  # `destinations` supersedes the deprecated `self_hosted_domains`. `domain` is
  # still what the App Launcher tile shows, so it is worth setting even when
  # destinations carry the real routing.
  domain       = lookup(each.value, "domain", null)
  destinations = lookup(each.value, "destinations", null)

  policies = lookup(each.value, "policies", null)

  allowed_idps              = lookup(each.value, "allowed_idps", null)
  auto_redirect_to_identity = lookup(each.value, "auto_redirect_to_identity", null)
  session_duration          = lookup(each.value, "session_duration", null)

  app_launcher_visible = lookup(each.value, "app_launcher_visible", null)
  cors_headers         = lookup(each.value, "cors_headers", null)

  enable_binding_cookie      = lookup(each.value, "enable_binding_cookie", null)
  http_only_cookie_attribute = lookup(each.value, "http_only_cookie_attribute", null)
  same_site_cookie_attribute = lookup(each.value, "same_site_cookie_attribute", null)
  path_cookie_attribute      = lookup(each.value, "path_cookie_attribute", null)

  allow_iframe        = lookup(each.value, "allow_iframe", null)
  skip_interstitial   = lookup(each.value, "skip_interstitial", null)
  custom_deny_message = lookup(each.value, "custom_deny_message", null)
  custom_deny_url     = lookup(each.value, "custom_deny_url", null)
  tags                = lookup(each.value, "tags", null)
}
