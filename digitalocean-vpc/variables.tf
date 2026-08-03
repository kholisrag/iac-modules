variable "vpcs" {
  description = <<-EOT
    Map of DigitalOcean VPCs to create. The map key is the VPC name unless the
    object sets `name`.

    Per-VPC keys mirror `digitalocean_vpc`:

      - `region`      (required) — the region slug the VPC lives in. A VPC is
                      regional; resources in another region cannot join it.
      - `description` (optional) — free text, 255 characters.
      - `ip_range`    (optional) — CIDR, no larger than /16 and no smaller than
                      /24, inside RFC1918, and not overlapping any other network
                      on the account. Left unset, DigitalOcean allocates one.

    Leaving `ip_range` to DigitalOcean and adding it later REPLACES the VPC.
    Every database cluster, Droplet and load balancer assigned to it has to
    leave first, so decide the range when the VPC is created.
  EOT
  type        = any
  default     = {}
}
