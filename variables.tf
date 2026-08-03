variable "account_id" {
  description = "Cloudflare account ID. Used for every service token unless one overrides it."
  type        = string
}

variable "service_tokens" {
  description = <<-EOT
    Map of Access service token objects to create. The map key is the token
    name unless the object sets `name`.

    Per-token keys mirror `cloudflare_zero_trust_access_service_token`:
    `name`, `account_id`, `zone_id`, `duration`, `client_secret_version`,
    `previous_client_secret_expires_at`.

    `duration` is REQUIRED by this module even though the provider treats it as
    optional — see the validation below. Format is `300ms` or `2h45m`; valid
    units are ns, us (or µs), ms, s, m, h.

    `account_id` and `zone_id` are mutually exclusive. A zone-scoped token must
    set `zone_id` and explicitly set `account_id = null`, or the API rejects it.

    To rotate: increment `client_secret_version` and set
    `previous_client_secret_expires_at` to the moment the old secret should stop
    working. Both secrets are accepted until then, which is the window for
    redeploying whatever holds the old one.

    A service token is only a reachability credential. It authenticates a
    request to Access; it is not an authorization model for whatever sits
    behind the application.
  EOT
  type        = any

  validation {
    condition = alltrue([
      for token in var.service_tokens : try(token.duration, null) != null
    ])
    error_message = "Every entry in `service_tokens` must set `duration` (e.g. \"720h\"). The provider defaults to 8760h — a year — and a credential whose lifetime nobody stated is one nobody has scheduled a rotation for. `duration = \"8760h\"` is a fine answer; not saying anything is not."
  }
}
