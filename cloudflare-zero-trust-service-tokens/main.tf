locals {
  service_tokens = {
    for i, token in var.service_tokens : i => merge(
      {
        name       = i
        account_id = var.account_id
      },
      token
    )
  }
}

resource "cloudflare_zero_trust_access_service_token" "service_token" {
  for_each = local.service_tokens

  account_id = lookup(each.value, "account_id", null)
  zone_id    = lookup(each.value, "zone_id", null)

  name = each.value.name

  # Not `lookup(…, null)` like its neighbours: `duration` is required here even
  # though the provider makes it optional. `variables.tf` says why and enforces
  # it.
  duration = each.value.duration

  # Rotation. Bumping `client_secret_version` mints a new `client_secret`; the
  # previous one keeps working until `previous_client_secret_expires_at`, so a
  # rotation is bump-then-redeploy-then-expire rather than a hard cutover. Move
  # that timestamp into the past to invalidate the old secret immediately.
  client_secret_version             = lookup(each.value, "client_secret_version", null)
  previous_client_secret_expires_at = lookup(each.value, "previous_client_secret_expires_at", null)
}
