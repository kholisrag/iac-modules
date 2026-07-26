locals {
  records = {
    for i, record in var.records : i => merge(
      {
        zone_id = var.zone_id
      },
      record
    )
  }
}

resource "cloudflare_dns_record" "record" {
  for_each = local.records

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl

  # `content` for the flat record types, `data` for the structured ones — CAA,
  # SRV, LOC, SSHFP and friends. Exactly one applies per record type, and the
  # API rejects both together.
  content = lookup(each.value, "content", null)
  data    = lookup(each.value, "data", null)

  priority        = lookup(each.value, "priority", null)
  proxied         = lookup(each.value, "proxied", null)
  private_routing = lookup(each.value, "private_routing", null)
  settings        = lookup(each.value, "settings", null)
  tags            = lookup(each.value, "tags", null)
  comment         = lookup(each.value, "comment", null)
}
