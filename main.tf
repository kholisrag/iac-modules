locals {
  default_profile = var.default_profile == null ? {} : {
    default = merge({ account_id = var.account_id }, var.default_profile)
  }

  default_fallback = {
    for i, profile in local.default_profile : i => profile
    if lookup(profile, "fallback_domains", null) != null
  }

  custom_profiles = {
    for i, profile in var.custom_profiles : i => merge(
      {
        name       = i
        account_id = var.account_id
      },
      profile
    )
  }

  custom_fallback = {
    for i, profile in local.custom_profiles : i => profile
    if lookup(profile, "fallback_domains", null) != null
  }
}

resource "cloudflare_zero_trust_device_default_profile" "default" {
  for_each = local.default_profile

  account_id = each.value.account_id

  include         = lookup(each.value, "include", null)
  exclude         = lookup(each.value, "exclude", null)
  service_mode_v2 = lookup(each.value, "service_mode_v2", null)

  allow_mode_switch                       = lookup(each.value, "allow_mode_switch", null)
  allow_updates                           = lookup(each.value, "allow_updates", null)
  allowed_to_leave                        = lookup(each.value, "allowed_to_leave", null)
  auto_connect                            = lookup(each.value, "auto_connect", null)
  captive_portal                          = lookup(each.value, "captive_portal", null)
  disable_auto_fallback                   = lookup(each.value, "disable_auto_fallback", null)
  dns_search_suffixes                     = lookup(each.value, "dns_search_suffixes", null)
  enable_device_credential_authentication = lookup(each.value, "enable_device_credential_authentication", null)
  exclude_office_ips                      = lookup(each.value, "exclude_office_ips", null)
  lan_allow_minutes                       = lookup(each.value, "lan_allow_minutes", null)
  lan_allow_subnet_size                   = lookup(each.value, "lan_allow_subnet_size", null)
  register_interface_ip_with_dns          = lookup(each.value, "register_interface_ip_with_dns", null)
  sccm_vpn_boundary_support               = lookup(each.value, "sccm_vpn_boundary_support", null)
  support_url                             = lookup(each.value, "support_url", null)
  switch_locked                           = lookup(each.value, "switch_locked", null)
  tunnel_protocol                         = lookup(each.value, "tunnel_protocol", null)
  uninstall_protection                    = lookup(each.value, "uninstall_protection", null)
}

resource "cloudflare_zero_trust_device_default_profile_local_domain_fallback" "default" {
  for_each = local.default_fallback

  account_id = each.value.account_id
  domains    = each.value.fallback_domains

  depends_on = [cloudflare_zero_trust_device_default_profile.default]
}

resource "cloudflare_zero_trust_device_custom_profile" "custom" {
  for_each = local.custom_profiles

  account_id  = each.value.account_id
  name        = each.value.name
  description = lookup(each.value, "description", null)
  match       = lookup(each.value, "match", null)
  precedence  = lookup(each.value, "precedence", null)
  enabled     = lookup(each.value, "enabled", null)

  include         = lookup(each.value, "include", null)
  exclude         = lookup(each.value, "exclude", null)
  service_mode_v2 = lookup(each.value, "service_mode_v2", null)

  allow_mode_switch                       = lookup(each.value, "allow_mode_switch", null)
  allow_updates                           = lookup(each.value, "allow_updates", null)
  allowed_to_leave                        = lookup(each.value, "allowed_to_leave", null)
  auto_connect                            = lookup(each.value, "auto_connect", null)
  captive_portal                          = lookup(each.value, "captive_portal", null)
  disable_auto_fallback                   = lookup(each.value, "disable_auto_fallback", null)
  dns_search_suffixes                     = lookup(each.value, "dns_search_suffixes", null)
  enable_device_credential_authentication = lookup(each.value, "enable_device_credential_authentication", null)
  exclude_office_ips                      = lookup(each.value, "exclude_office_ips", null)
  lan_allow_minutes                       = lookup(each.value, "lan_allow_minutes", null)
  lan_allow_subnet_size                   = lookup(each.value, "lan_allow_subnet_size", null)
  register_interface_ip_with_dns          = lookup(each.value, "register_interface_ip_with_dns", null)
  sccm_vpn_boundary_support               = lookup(each.value, "sccm_vpn_boundary_support", null)
  support_url                             = lookup(each.value, "support_url", null)
  switch_locked                           = lookup(each.value, "switch_locked", null)
  tunnel_protocol                         = lookup(each.value, "tunnel_protocol", null)
  uninstall_protection                    = lookup(each.value, "uninstall_protection", null)
}

resource "cloudflare_zero_trust_device_custom_profile_local_domain_fallback" "custom" {
  for_each = local.custom_fallback

  account_id = each.value.account_id
  policy_id  = cloudflare_zero_trust_device_custom_profile.custom[each.key].policy_id
  domains    = each.value.fallback_domains
}
