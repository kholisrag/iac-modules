# cloudflare-turnstile

OpenTofu module for `cloudflare turnstile widget resources`.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-turnstile/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_turnstile" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-turnstile/v0.1.0"
}
```

Floating tags `cloudflare-turnstile/v0` and `cloudflare-turnstile/v0.1` track the latest matching release.

## Things that bite

**`region` cannot be changed after creation.** Changing it destroys and recreates
the widget, which rotates the sitekey and breaks every page still embedding the
old one.

**`secret` is in state.** Encrypt the state of any stack consuming this module.

**`bot_fight_mode`, `ephemeral_id`, and `offlabel` are Enterprise-only** and are
rejected on other plans.

**`domains` is exact-host matching.** A widget listing `example.com` does not
serve `www.example.com`; list both.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
