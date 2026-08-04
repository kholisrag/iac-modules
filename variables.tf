variable "account_id" {
  description = "Cloudflare account ID. Used for every tunnel unless one overrides it."
  type        = string
}

variable "tunnels" {
  description = <<-EOT
    Map of `cloudflared` tunnel objects to create. The map key is the tunnel
    name unless the object sets `name`.

    Per-tunnel keys mirror `cloudflare_zero_trust_tunnel_cloudflared`: `name`,
    `account_id`, `config_src`, `tunnel_secret`.

    An optional `ingress` list creates the tunnel's remote configuration. Each
    entry mirrors `config.ingress`: `service` (required), `hostname`, `path`,
    `origin_request`. An optional `origin_request` at the tunnel level sets the
    connection defaults every ingress rule inherits.

    Ingress is only meaningful when `config_src = "cloudflare"`. A `local`
    tunnel reads its rules from a YAML file on the origin machine, and a config
    resource declared here would be silently ignored.

    Cloudflare requires the LAST ingress rule to be a catch-all with no
    `hostname`, usually `service = "http_status:404"`. The API rejects a config
    without one, so the module does not add it for you — a hidden default here
    would be a hidden route.
  EOT
  type        = any
}
