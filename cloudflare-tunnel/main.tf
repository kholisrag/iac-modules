locals {
  tunnels = {
    for i, tunnel in var.tunnels : i => merge(
      {
        name       = i
        account_id = var.account_id
      },
      tunnel
    )
  }

  configured_tunnels = {
    for i, tunnel in local.tunnels : i => tunnel
    if length(lookup(tunnel, "ingress", [])) > 0
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  for_each = local.tunnels

  account_id = each.value.account_id
  name       = each.value.name
  config_src = lookup(each.value, "config_src", null)

  # Locally-managed tunnels only. A remotely-managed tunnel authenticates with
  # the connector token instead — see the `tunnel_token` output.
  tunnel_secret = lookup(each.value, "tunnel_secret", null)

  # A literal, not a variable: Terraform rejects a variable in `prevent_destroy`
  # at parse, and the argument cannot read `each.value`, so this can be neither
  # configurable nor per-tunnel. Why the guard is here, and how to remove a
  # tunnel you do own, are in README.md § "Things that bite".
  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "config" {
  for_each = local.configured_tunnels

  account_id = each.value.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel[each.key].id

  config = {
    ingress        = each.value.ingress
    origin_request = lookup(each.value, "origin_request", null)
  }
}

# The token is what `cloudflared` actually runs with, and it exists only after
# the tunnel does. Reading it here means the credential never has to be copied
# out of the dashboard by hand — but it does land in state, which is why every
# stack consuming this module encrypts its state.
data "cloudflare_zero_trust_tunnel_cloudflared_token" "token" {
  for_each = local.tunnels

  account_id = each.value.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel[each.key].id
}
