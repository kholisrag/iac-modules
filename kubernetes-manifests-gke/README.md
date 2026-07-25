# kubernetes-manifests-gke

OpenTofu module for `kubernetes manifests gke` resources.

Migrated from `kholisrag/labirin` `modules/opentofu/kubernetes/manifests/gke/0.1.0`.

## Requirements

| Provider | Source | Version |
| --- | --- | --- |
| `google` | `hashicorp/google` | `>= 6.0.0, < 7.0.0` |
| `helm` | `hashicorp/helm` | `>= 3.0.0, < 4.0.0` |
| `kubectl` | `alekc/kubectl` | `>= 2.0.0, < 3.0.0` |

## Usage

Releases are cut per module by release-please. Each release publishes an orphan tag
whose root **is** this module, so no `//<subdir>` selector is needed:

### Terragrunt

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=kubernetes-manifests-gke/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "kubernetes_manifests_gke" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=kubernetes-manifests-gke/v0.1.0"
}
```

Floating tags `kubernetes-manifests-gke/v0` and `kubernetes-manifests-gke/v0.1` track the latest matching release.

See `variables.tf` / `variables.tofu` for the full input surface, and `outputs.tf` / `outputs.tofu` for what is exposed.
