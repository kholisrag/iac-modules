variable "account_id" {
  description = "Cloudflare account ID. Used for every zone unless one overrides it."
  type        = string
}

variable "zones" {
  description = <<-EOT
    Map of zone objects to create. The map key is the domain name unless the
    object sets `name`.

    Per-zone keys mirror `cloudflare_zone`: `name`, `account_id`, `type`,
    `paused`, `vanity_name_servers`.

    An optional `settings` map of `setting_id => value` creates one
    `cloudflare_zone_setting` per entry. Values are dynamic — a string, number,
    list, or object depending on the setting.

    `ssl_recommender` is deliberately unsupported here: it is the one setting
    that takes `enabled` instead of `value`, and special-casing it in a generic
    map would hide the exception. Declare it directly if you need it.
  EOT
  type        = any
}
