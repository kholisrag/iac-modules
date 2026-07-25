# proxmox-cluster-options

OpenTofu module for `proxmox cluster options` resources.

Migrated from `kholisrag/labirin` `modules/opentofu/proxmox/cluster-options/0.1.0`.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=proxmox-cluster-options/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "proxmox_cluster_options" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=proxmox-cluster-options/v0.1.0"
}
```

Floating tags `proxmox-cluster-options/v0` and `proxmox-cluster-options/v0.1` track the latest matching release.

See `variables.tf` / `variables.tofu` for the full input surface, and `outputs.tf` / `outputs.tofu` for what is exposed.
