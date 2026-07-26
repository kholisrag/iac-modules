locals {
  destination_addresses = {
    for i, address in var.destination_addresses : i => merge(
      {
        email      = i
        account_id = var.account_id
      },
      address
    )
  }

  settings = {
    for i, setting in var.settings : i => merge(
      {
        zone_id = var.zone_id
      },
      setting
    )
  }

  rules = {
    for i, rule in var.rules : i => merge(
      {
        name    = i
        zone_id = var.zone_id
      },
      rule
    )
  }
}

resource "cloudflare_email_routing_address" "address" {
  for_each = local.destination_addresses

  account_id = each.value.account_id
  email      = each.value.email
}

resource "cloudflare_email_routing_settings" "settings" {
  for_each = local.settings

  zone_id = each.value.zone_id
}

resource "cloudflare_email_routing_rule" "rule" {
  for_each = local.rules

  zone_id  = each.value.zone_id
  name     = each.value.name
  matchers = each.value.matchers
  actions  = each.value.actions
  enabled  = lookup(each.value, "enabled", null)
  priority = lookup(each.value, "priority", null)

  # Routing must be enabled on the zone before a rule can be created, and
  # nothing in the rule's own arguments expresses that.
  depends_on = [cloudflare_email_routing_settings.settings]
}
