locals {
  zones = {
    for i, zone in var.zones : i => merge(
      {
        name       = i
        account_id = var.account_id
      },
      zone
    )
  }

  # Flattened to one entry per (zone, setting). The value is deliberately left
  # out of this structure and read from `local.zones` at resource time: zone
  # setting values are heterogeneous — string, number, list, object — and
  # carrying them through a flatten() would force HCL to unify those types and
  # fail on the first zone that mixes them.
  zone_settings = {
    for pair in flatten([
      for zone_key, zone in local.zones : [
        for setting_id in keys(lookup(zone, "settings", {})) : {
          key        = "${zone_key}/${setting_id}"
          zone_key   = zone_key
          setting_id = setting_id
        }
      ]
    ]) : pair.key => pair
  }
}

resource "cloudflare_zone" "zone" {
  for_each = local.zones

  account = {
    id = each.value.account_id
  }

  name                = each.value.name
  type                = lookup(each.value, "type", null)
  paused              = lookup(each.value, "paused", null)
  vanity_name_servers = lookup(each.value, "vanity_name_servers", null)
}

resource "cloudflare_zone_setting" "setting" {
  for_each = local.zone_settings

  zone_id    = cloudflare_zone.zone[each.value.zone_key].id
  setting_id = each.value.setting_id
  value      = local.zones[each.value.zone_key].settings[each.value.setting_id]
}
