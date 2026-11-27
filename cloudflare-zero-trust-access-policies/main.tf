locals {
  policies = {
    for i, policy in var.policies : i => merge(
      {
        name       = i
        account_id = var.account_id
      },
      policy
    )
  }
}

resource "cloudflare_zero_trust_access_policy" "policy" {
  for_each = local.policies

  # Account-level only: the provider has no `zone_id` on a reusable policy.
  account_id = each.value.account_id

  name = each.value.name

  # Not `lookup(…, null)` like its neighbours: the provider requires `decision`,
  # and `variables.tf` validates it so the error names the offending input.
  decision = each.value.decision

  include = lookup(each.value, "include", null)
  exclude = lookup(each.value, "exclude", null)
  require = lookup(each.value, "require", null)

  session_duration = lookup(each.value, "session_duration", null)

  approval_required = lookup(each.value, "approval_required", null)
  approval_groups   = lookup(each.value, "approval_groups", null)

  purpose_justification_required = lookup(each.value, "purpose_justification_required", null)
  purpose_justification_prompt   = lookup(each.value, "purpose_justification_prompt", null)

  isolation_required = lookup(each.value, "isolation_required", null)
  mfa_config         = lookup(each.value, "mfa_config", null)
  connection_rules   = lookup(each.value, "connection_rules", null)
}
