variable "account_id" {
  description = "Cloudflare account ID. Used for every managed network unless one overrides it."
  type        = string
}

variable "managed_networks" {
  description = <<-EOT
    Map of managed networks (network locations) the Cloudflare One client
    detects by probing a TLS endpoint. The map key is the network name unless
    the object sets `name` — and that NAME is what a device profile matches on:
    `network == "<name>"`.

    Per-network keys:
    - `tls_sockaddr` (required): `<private-ip>:<port>` of the endpoint. Use an
      IP, not a hostname — the client only auto-excludes an IP from tunnel
      routing, and a hostname can resolve wrong before detection finishes.
    - `sha256`: SHA-256 fingerprint of the endpoint certificate, hex, no
      colons. Required for a self-signed cert; without it the client wants a
      publicly-trusted chain.
    - `type`: defaults to `tls`, the only type the API accepts today.
    - `account_id`, `name`.
  EOT
  type        = any
  default     = {}
}
