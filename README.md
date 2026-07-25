# kubernetes-manifests-talos

OpenTofu module for `kubernetes manifests talos` resources.

Migrated from `kholisrag/labirin` `modules/opentofu/kubernetes/manifests/talos/0.1.0`.

## Requirements

| Provider | Source | Version |
| --- | --- | --- |
| `helm` | `hashicorp/helm` | `>= 3.0.0, < 4.0.0` |
| `kubectl` | `alekc/kubectl` | `>= 2.0.0, < 3.0.0` |
| `proxmox` | `bpg/proxmox` | `>= 0.86.0` |

## Usage

Releases are cut per module by release-please. Each release publishes an orphan tag
whose root **is** this module, so no `//<subdir>` selector is needed:

### Terragrunt

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=kubernetes-manifests-talos/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "kubernetes_manifests_talos" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=kubernetes-manifests-talos/v0.1.0"
}
```

Floating tags `kubernetes-manifests-talos/v0` and `kubernetes-manifests-talos/v0.1` track the latest matching release.

See `variables.tf` / `variables.tofu` for the full input surface, and `outputs.tf` / `outputs.tofu` for what is exposed.
