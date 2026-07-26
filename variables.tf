variable "zone_id" {
  description = "Cloudflare zone ID. Used for every record unless one overrides it."
  type        = string
}

variable "records" {
  description = <<-EOT
    Map of DNS record objects to create. The map key is a stable identifier for
    the record — it is NOT the record name, because a zone routinely holds
    several records with the same name and different types.

    Per-record keys mirror `cloudflare_dns_record`: `name`, `type`, `ttl`,
    `content`, `data`, `priority`, `proxied`, `settings`, `tags`, `comment`,
    `private_routing`, `zone_id`.

    `ttl = 1` means automatic, and is the only accepted value for a proxied
    record.
  EOT
  type        = any
}
