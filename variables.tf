variable "account_id" {
  description = "Cloudflare account ID. Used for every destination address unless one overrides it."
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID. Used for settings and rules unless one overrides it."
  type        = string
  default     = null
}

variable "destination_addresses" {
  description = <<-EOT
    Map of `cloudflare_email_routing_address` objects — the real mailboxes that
    forwarded mail lands in. Account-level, not zone-level: one address serves
    every zone on the account. The map key is the email address unless the
    object sets `email`.

    **Every destination address must be verified by clicking a link in an email
    Cloudflare sends to it.** Tofu creates the address in `unverified` state and
    stops; a forwarding rule pointing at an unverified address silently drops
    mail. This is a human step with no API substitute.
  EOT
  type        = any
  default     = {}
}

variable "settings" {
  description = <<-EOT
    Map of `cloudflare_email_routing_settings` objects, keyed by an identifier
    of your choosing, each optionally overriding `zone_id`.

    This resource has no writable attributes beyond `zone_id` — it enables Email
    Routing for the zone and reports status. Enabling it does not create the MX
    and TXT records the zone needs; declare those with `cloudflare-dns-records`
    or the zone stays `misconfigured`.
  EOT
  type        = any
  default     = {}
}

variable "rules" {
  description = <<-EOT
    Map of `cloudflare_email_routing_rule` objects. The map key is the rule name
    unless the object sets `name`.

    Per-rule keys: `matchers` (required), `actions` (required), `name`,
    `enabled`, `priority`, `zone_id`.

    A matcher is `{ type = "literal", field = "to", value = "..." }` for one
    address, or `{ type = "all" }` for a catch-all. An action is
    `{ type = "forward", value = ["dest@example.com"] }`, or type `drop` or
    `worker`.

    Forward actions may only target a VERIFIED destination address.
  EOT
  type        = any
  default     = {}
}
