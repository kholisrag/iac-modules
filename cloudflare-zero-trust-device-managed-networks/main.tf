locals {
  managed_networks = {
    for i, network in var.managed_networks : i => merge(
      {
        name       = i
        type       = "tls"
        account_id = var.account_id
      },
      network
    )
  }
}

resource "cloudflare_zero_trust_device_managed_networks" "managed_network" {
  for_each = local.managed_networks

  account_id = each.value.account_id
  name       = each.value.name
  type       = each.value.type

  config = {
    tls_sockaddr = each.value.tls_sockaddr
    # The API stores the fingerprint lowercase and without separators; feed it
    # the same shape so a pasted `openssl -fingerprint` value is not a
    # perpetual diff.
    sha256 = (
      lookup(each.value, "sha256", null) == null
      ? null
      : lower(replace(each.value.sha256, ":", ""))
    )
  }
}
