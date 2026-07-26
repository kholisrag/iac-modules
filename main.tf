locals {
  widgets = {
    for i, widget in var.widgets : i => merge(
      {
        name       = i
        account_id = var.account_id
      },
      widget
    )
  }
}

resource "cloudflare_turnstile_widget" "widget" {
  for_each = local.widgets

  account_id = each.value.account_id
  name       = each.value.name
  domains    = each.value.domains
  mode       = each.value.mode

  clearance_level = lookup(each.value, "clearance_level", null)
  region          = lookup(each.value, "region", null)
  bot_fight_mode  = lookup(each.value, "bot_fight_mode", null)
  ephemeral_id    = lookup(each.value, "ephemeral_id", null)
  offlabel        = lookup(each.value, "offlabel", null)
}
