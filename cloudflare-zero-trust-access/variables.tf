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
    `allowed_idps`, `auto_redirect_to_identity`, `app_launcher_visible`,
    `cors_headers`, `policies`, `tags`, and the cookie-attribute flags.

    Policies are declared INLINE on the application via `policies`, each with
    `name`, `decision`, `precedence`, and `include` / `exclude` / `require`
    rule sets. That is the v5 provider's model; there is no separate policy
    resource to attach afterwards.

    `account_id` and `zone_id` are mutually exclusive. An application scoped to
    a zone must set `zone_id` and explicitly set `account_id = null`, or the
    API rejects it.

    Access is DEFAULT-DENY. An application with destinations and no allow
    policy is reachable by nobody — which is the safe failure, but it is a
    failure, not a no-op.
  EOT
  type        = any
}
