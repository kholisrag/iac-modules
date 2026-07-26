# cloudflare-email-routing

OpenTofu module for `cloudflare email routing resources`.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-email-routing/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_email_routing" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-email-routing/v0.1.0"
}
```

Floating tags `cloudflare-email-routing/v0` and `cloudflare-email-routing/v0.1` track the latest matching release.

## Things that bite

**Every destination address must be verified by a human.** Cloudflare emails a
link to it; Tofu creates the address `unverified` and stops. A forward rule
pointing at an unverified address **drops mail without erroring**. The
`unverified_addresses` output is the list to check after an apply.

**Enabling Email Routing does not create the DNS records it needs.** The zone
stays `misconfigured` until the MX and TXT records exist — declare them with
`cloudflare-dns-records`.

**Destination addresses are account-level; rules and settings are zone-level.**
One verified mailbox serves every zone on the account.

**Rule order is `priority`, ascending.** A catch-all (`{ type = "all" }`) at a
lower priority than a literal matcher swallows the mail the literal rule was
written for.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
