locals {
  virtual_networks = {
    for i, vnet in var.virtual_networks : i => merge(
      {
        name       = i
        account_id = var.account_id
      },
      vnet
    )
  }

  routes = {
    for i, route in var.routes : i => merge(
      {
        account_id = var.account_id
      },
      route
    )
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared_virtual_network" "virtual_network" {
  for_each = local.virtual_networks

  account_id         = each.value.account_id
  name               = each.value.name
  comment            = lookup(each.value, "comment", null)
  is_default_network = lookup(each.value, "is_default_network", null)
}

resource "cloudflare_zero_trust_tunnel_cloudflared_route" "route" {
  for_each = local.routes

  account_id = each.value.account_id
  network    = each.value.network
  tunnel_id  = each.value.tunnel_id
  comment    = lookup(each.value, "comment", null)

  virtual_network_id = (
    lookup(each.value, "virtual_network", null) != null
    ? cloudflare_zero_trust_tunnel_cloudflared_virtual_network.virtual_network[each.value.virtual_network].id
    : lookup(each.value, "virtual_network_id", null)
  )
}
