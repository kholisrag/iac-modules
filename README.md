# proxmox-apt-standard-repository

OpenTofu module for `proxmox apt standard repository` resources.

Migrated from `kholisrag/labirin` `modules/opentofu/proxmox/apt-standard-repository/0.1.0`.

## Requirements

| Provider | Source | Version |
| --- | --- | --- |
| `proxmox` | `bpg/proxmox` | `>= 0.86.0` |

## Usage

Releases are cut per module by release-please. Each release publishes an orphan tag
whose root **is** this module, so no `//<subdir>` selector is needed:

### Terragrunt

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=proxmox-apt-standard-repository/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "proxmox_apt_standard_repository" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=proxmox-apt-standard-repository/v0.1.0"
}
```

Floating tags `proxmox-apt-standard-repository/v0` and `proxmox-apt-standard-repository/v0.1` track the latest matching release.

See `variables.tf` / `variables.tofu` for the full input surface, and `outputs.tf` / `outputs.tofu` for what is exposed.
