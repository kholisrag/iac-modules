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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-access/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_zero_trust_access" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-access/v0.1.0"
}
```

Floating tags `cloudflare-zero-trust-access/v0` and `cloudflare-zero-trust-access/v0.1` track the latest matching release.

## Things that bite

**Access is default-deny.** An application with destinations and no allow policy
is reachable by nobody. That is the safe failure, but it is a failure, not a
no-op.

**Policies are inline.** The v5 provider attaches them through the application's
`policies` list, each with `include` / `exclude` / `require` rule sets. There is
no separate policy resource to bind afterwards.

**`account_id` and `zone_id` are mutually exclusive.** This module defaults
`account_id` from `var.account_id`, so a zone-scoped application must set
`zone_id` *and* `account_id = null` explicitly.

**`precedence` must be unique within an application.** Two policies at the same
precedence is an apply-time error, not a plan-time one.

**Access authorizes; it does not inspect traffic.** Reaching an application is
not the same as what happens inside it.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
