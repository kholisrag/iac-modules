# cloudflare-zero-trust-device-profiles

OpenTofu module for `cloudflare zero trust device profiles (default and custom) and their local domain fallback`.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-device-profiles/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_zero_trust_device_profiles" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-device-profiles/v0.1.0"
}
```

Floating tags `cloudflare-zero-trust-device-profiles/v0` and `cloudflare-zero-trust-device-profiles/v0.1` track the latest matching release.

## Things that bite

**The default profile is adopted, never created.** Import it with the
account ID before the first apply. Removing `default_profile` from the inputs
deletes the resource from state; Cloudflare keeps the profile with whatever
settings it last had.

**`include` and `exclude` are mutually exclusive** — setting one picks the
Split Tunnel mode for that profile.

**`fallback_domains` replaces the whole Local Domain Fallback list,**
including the built-in suffixes (`local`, `home.arpa`, `internal`, …). Carry
them over explicitly if you still want them.

**A `match` that names a missing managed network never matches** and the
device silently gets the default profile. Source the name from the
managed-networks module output.

**Lower `precedence` wins.** A broad profile (e.g. all mobile OSes) at a lower
number than a location profile shadows the location profile.
