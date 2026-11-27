variable "account_id" {
  description = "Cloudflare account ID. Used for every application unless one overrides it."
  type        = string
}

variable "applications" {
  description = <<-EOT
    Map of Access application objects to create. The map key is the application
    name unless the object sets `name`.

    Per-application keys mirror `cloudflare_zero_trust_access_application`:
    `name`, `type`, `domain`, `destinations`, `session_duration`,
    `allowed_idps`, `auto_redirect_to_identity`, `allow_authenticate_via_warp`,
    `app_launcher_visible`, `cors_headers`, `policies`, `tags`, and the
    cookie-attribute flags.

    `policies` is a list, and each entry takes one of two forms:

    - A REFERENCE to a reusable policy: `{ id = "<policy id>", precedence = 1 }`.
      The policy itself is a `cloudflare_zero_trust_access_policy`, created by
      the `cloudflare-zero-trust-access-policies` module (its `ids` output) or
      anywhere else. One policy can be attached to many applications.
    - An INLINE policy: `name`, `decision`, `precedence`, and `include` /
      `exclude` / `require` rule sets. It exists only on this application, and
      the dashboard labels it Legacy.

    Both forms can be mixed in one list. `precedence` belongs to the
    application in either form and must be unique within it.

    `allow_authenticate_via_warp = true` lets a device's WARP / Cloudflare One
    Client session count as the user's identity for this application, with no
    IdP prompt. `false` always requires a direct IdP login. Either value
    overrides the organisation-wide setting; leaving it unset inherits it.

    `account_id` and `zone_id` are mutually exclusive. An application scoped to
    a zone must set `zone_id` and explicitly set `account_id = null`, or the
    API rejects it.

    Access is DEFAULT-DENY. An application with destinations and no allow
    policy is reachable by nobody — which is the safe failure, but it is a
    failure, not a no-op.
  EOT
  type        = any
}
