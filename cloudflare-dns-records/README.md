# cloudflare-dns-records

OpenTofu module for `cloudflare dns record resources`.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-dns-records/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_dns_records" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-dns-records/v0.1.0"
}
```

Floating tags `cloudflare-dns-records/v0` and `cloudflare-dns-records/v0.1` track the latest matching release.

## Things that bite

**The map key is not the record name.** A zone routinely holds an A and an MX at
the same name, and several MX records at one name. The key is a stable
identifier you choose; changing it destroys and recreates the record.

**`ttl` must be `1` for a proxied record.** Any other value is rejected. `1`
means automatic.

**`content` and `data` are mutually exclusive.** Flat types (A, AAAA, CNAME,
TXT) use `content`; structured ones (CAA, SRV, LOC, SSHFP, TLSA) use `data`. The
API rejects both together.

**A proxied record hides the origin IP but publishes the hostname.** Proxying is
not concealment of what exists, only of where it is.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
