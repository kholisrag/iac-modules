# cloudflare-zero-trust-access

OpenTofu module for `cloudflare zero trust access application resources`.

## Requirements

| Provider | Source | Version |
| --- | --- | --- |
| `cloudflare` | `cloudflare/cloudflare` | `>= 5.22.0` |

## Usage

Releases are cut per module by release-please. Each release publishes an orphan tag
whose root **is** this module, so no `//<subdir>` selector is needed:

### Terragrunt

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-access/v0.2.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_zero_trust_access" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-access/v0.2.0"

  account_id = var.account_id

  applications = {
    wiki = {
      type   = "self_hosted"
      domain = "wiki.example.com"

      # A device's Cloudflare One Client session counts as identity for this
      # application, whatever the organisation-wide setting says.
      allow_authenticate_via_warp = true

      # Reusable policies, attached by ID, with the order set here.
      policies = [
        { id = module.access_policies.ids["contractors-blocked"], precedence = 1 },
        { id = module.access_policies.ids["staff"], precedence = 2 },
      ]
    }
  }
}
```

Floating tags `cloudflare-zero-trust-access/v0` and `cloudflare-zero-trust-access/v0.2` track the latest matching release.

## Policies: reusable or inline

Each entry of an application's `policies` list takes one of two forms, and one
list can mix them.

**A reference to a reusable policy** is `{ id, precedence }`. The policy is an
account-level `cloudflare_zero_trust_access_policy`, created by
[`cloudflare-zero-trust-access-policies`](../cloudflare-zero-trust-access-policies)
and read from its `ids` output, as in the example above. One policy serves many
applications. Prefer this form.

**An inline policy** is written out on the application and exists only there.
The dashboard labels it **Legacy**:

```hcl
policies = [{
  name       = "staff"
  decision   = "allow"
  precedence = 1
  include    = [{ email_domain = { domain = "example.com" } }]
}]
```

If a rule uses device posture, point `device_posture.integration_uid` at a
**Gateway**-type posture check (the Cloudflare One Client enrolled in your
organisation), not a **WARP**-type one, which any consumer 1.1.1.1 client
passes.

## Things that bite

**Access is default-deny.** An application with destinations and no allow policy
is reachable by nobody. That is the safe failure, but it is a failure, not a
no-op.

**Moving an inline policy to a reusable one is a replacement, not a rename.**
Dropping an inline policy from the list deletes it, and the reusable policy
that takes its place has a new ID. Both happen in one apply when the reference
is added in the same change.

**`allow_authenticate_via_warp` overrides the organisation, in both directions.**
`true` accepts a WARP session as identity for this application; `false` forces
an IdP login even when the organisation allows WARP. Leave it unset to inherit.

**`account_id` and `zone_id` are mutually exclusive.** This module defaults
`account_id` from `var.account_id`, so a zone-scoped application must set
`zone_id` *and* `account_id = null` explicitly.

**`precedence` must be unique within an application.** Two policies at the same
precedence is an apply-time error, not a plan-time one.

**Access authorizes; it does not inspect traffic.** Reaching an application is
not the same as what happens inside it.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
