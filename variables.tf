variable "account_id" {
  description = "Cloudflare account ID. Used for the default profile and every custom profile unless one overrides it."
  type        = string
}

variable "default_profile" {
  description = <<-EOT
    Settings for the account's DEFAULT device profile, or null to leave it
    unmanaged. The default profile always exists — it cannot be created or
    deleted, only adopted: import it (`import { id = "<account_id>" }`) before
    the first apply.

    Keys mirror `cloudflare_zero_trust_device_default_profile`: `include` /
    `exclude` (mutually exclusive, lists of `{ address | host, description }`),
    `service_mode_v2`, `auto_connect`, `captive_portal`, `allow_mode_switch`,
    `allow_updates`, `allowed_to_leave`, `switch_locked`, `support_url`,
    `tunnel_protocol`, `disable_auto_fallback`, `exclude_office_ips`,
    `register_interface_ip_with_dns`, `sccm_vpn_boundary_support`,
    `enable_device_credential_authentication`, `uninstall_protection`,
    `dns_search_suffixes`, `lan_allow_minutes`, `lan_allow_subnet_size`.

    `fallback_domains` (list of `{ suffix, description, dns_server }`) manages
    the profile's Local Domain Fallback list as a separate resource. Declaring
    it REPLACES the whole list — including the built-in `local`, `home.arpa`,
    etc. entries — so carry those over if you still want them.
  EOT
  type        = any
  default     = null
}

variable "custom_profiles" {
  description = <<-EOT
    Map of custom device profiles. The map key is the profile name unless the
    object sets `name`.

    Takes every `default_profile` key, plus:
    - `match` (required in practice): wirefilter expression selecting devices,
      e.g. `network == "home"` or `os.name in {"android" "ios"}`.
    - `precedence`: lower wins. The first profile whose `match` is true
      applies; nothing matching falls through to the default profile.
    - `description`, `enabled`, `account_id`, `name`.

    A profile matching a managed network that does not exist never matches,
    and the device silently gets the default profile. Feed `match` from the
    managed-networks module's `managed_network_names` output, not a literal.
  EOT
  type        = any
  default     = {}
}
