# cloudflare-zero-trust-access-policies

OpenTofu module for `cloudflare zero trust access reusable policy resources`.

A reusable policy is an account-level `cloudflare_zero_trust_access_policy`:
written once, attached to any number of applications by ID. Applications live in
[`cloudflare-zero-trust-access`](../cloudflare-zero-trust-access); this module
only creates the policies they reference.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-access-policies/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "access_policies" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-access-policies/v0.1.0"

  account_id = var.account_id

  policies = {
    staff = {
      decision = "allow"
      include  = [{ email_domain = { domain = "example.com" } }]

      # A Gateway-type posture check: the device runs the Cloudflare One Client
      # enrolled in THIS organisation. See "Things that bite".
      require = [{ device_posture = { integration_uid = var.gateway_posture_rule_id } }]

      session_duration = "12h"
    }

    contractors-blocked = {
      name     = "Block contractors"
      decision = "deny"
      include  = [{ email_list = { id = var.contractors_list_id } }]
    }
  }
}
```

Floating tags `cloudflare-zero-trust-access-policies/v0` and `cloudflare-zero-trust-access-policies/v0.1` track the latest matching release.

## Attaching a policy to an application

An application references a policy by ID and gives it a `precedence`. The policy
has no precedence of its own, so the same one can sit first on one application
and last on another:

```hcl
module "access" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-access/v0.2.0"

  account_id = var.account_id

  applications = {
    wiki = {
      type   = "self_hosted"
      domain = "wiki.example.com"

      policies = [
        { id = module.access_policies.ids["contractors-blocked"], precedence = 1 },
        { id = module.access_policies.ids["staff"], precedence = 2 },
      ]
    }

    grafana = {
      type   = "self_hosted"
      domain = "grafana.example.com"

      policies = [
        { id = module.access_policies.ids["staff"], precedence = 1 },
      ]
    }
  }
}
```

With Terragrunt the two modules are separate units: declare a `dependency` on
the policies unit and read `dependency.access_policies.outputs.ids["staff"]`.

## Things that bite

**For device posture, use a Gateway-type check, not a WARP-type one.** A
**WARP** posture check passes for any device running the client, including the
consumer 1.1.1.1 app that anyone can install. A **Gateway** check passes only
when the Cloudflare One Client is enrolled in your organisation and sending its
traffic through your Gateway. The rule object
looks the same either way (`device_posture = { integration_uid = ... }`); which
posture check that ID points at is the whole difference.

**Editing a policy changes every application that uses it.** That is the point
of reuse, and it also means nothing in the plan lists the affected applications:
the diff shows one policy.

**A policy still attached to an application cannot be deleted.** Remove the
reference from every application first, apply, then remove the policy. In one
stack OpenTofu orders that for you; across two stacks it is two applies, the
application stack first.

**A policy with no `include` matches nobody.** `require` and `exclude` only
narrow what `include` let in.

**Precedence is not here.** It is set per application, where the policy is
attached, and must be unique within that application.

**Policies are account-level.** There is no `zone_id`.

**`policy_resolution_account_id` is not passed through.** The provider added it
in 5.29.0 and this module supports `>= 5.22.0`.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
