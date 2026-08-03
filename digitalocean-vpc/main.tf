locals {
  vpcs = {
    for i, vpc in var.vpcs : i => merge(
      {
        name = i
      },
      vpc
    )
  }
}

resource "digitalocean_vpc" "vpc" {
  for_each = local.vpcs

  name   = each.value.name
  region = each.value.region

  description = lookup(each.value, "description", null)

  # Omitting this lets DigitalOcean allocate a range, and the allocation is
  # made once. A range added to this map afterwards is a replacement of the
  # VPC, which every resource assigned to it has to be moved out of first.
  #
  # It may not be larger than /16 nor smaller than /24, and it must not overlap
  # another network in the same account — including the per-region default VPC
  # DigitalOcean creates whether or not anything uses it.
  ip_range = lookup(each.value, "ip_range", null)
}
