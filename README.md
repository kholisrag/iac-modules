# cloudflare-zone

OpenTofu module for `cloudflare zone and zone setting resources`.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zone/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_zone" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zone/v0.1.0"
}
```

Floating tags `cloudflare-zone/v0` and `cloudflare-zone/v0.1` track the latest matching release.

## Things that bite

**Zone creation does not switch your nameservers.** Cloudflare assigns
nameservers on creation and the zone stays `pending` until the registrar points
at them. Read `name_servers` from the output and change them at the registrar.

**`ssl_recommender` is not supported through the `settings` map.** It is the one
zone setting that takes `enabled` instead of `value`. Special-casing it inside a
generic map would hide the exception from whoever reads the map next; declare
the resource directly instead.

**Setting values are dynamic and plan-visible.** A number written as `"14400"`
is a string to Cloudflare and produces a perpetual diff. Match the type in the
provider's setting table.

**Deleting a `cloudflare_zone_setting` does not restore the default.** It only
stops managing it, leaving the last applied value in place.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
