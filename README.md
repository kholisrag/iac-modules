# kubernetes-manifests-eks

OpenTofu module for `kubernetes manifests eks` resources.

Migrated from `kholisrag/labirin` `modules/opentofu/kubernetes/manifests/eks/0.1.0`.

## Requirements

| Provider | Source | Version |
| --- | --- | --- |
| `helm` | `hashicorp/helm` | `>= 3.0.0, < 4.0.0` |
| `kubectl` | `alekc/kubectl` | `>= 2.0.0, < 3.0.0` |

## Usage

Releases are cut per module by release-please. Each release publishes an orphan tag
whose root **is** this module, so no `//<subdir>` selector is needed:

### Terragrunt

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=kubernetes-manifests-eks/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "kubernetes_manifests_eks" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=kubernetes-manifests-eks/v0.1.0"
}
```

Floating tags `kubernetes-manifests-eks/v0` and `kubernetes-manifests-eks/v0.1` track the latest matching release.

See `variables.tf` / `variables.tofu` for the full input surface, and `outputs.tf` / `outputs.tofu` for what is exposed.
