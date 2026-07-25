# aws-vpc

Wrapper around the upstream `terraform-aws-modules/vpc/aws` module pinned at `v6.5.1`.

Migrated from `kholisrag/labirin` `modules/opentofu/aws/vpc/v6.5.1`.

## Requirements

| Provider | Source | Version |
| --- | --- | --- |
| `aws` | `hashicorp/aws` | `>= 6.23.0` |

## Usage

Releases are cut per module by release-please. Each release publishes an orphan tag
whose root **is** this module, so no `//<subdir>` selector is needed:

### Terragrunt

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=aws-vpc/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "aws_vpc" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=aws-vpc/v0.1.0"
}
```

Floating tags `aws-vpc/v0` and `aws-vpc/v0.1` track the latest matching release.

See `variables.tf` / `variables.tofu` for the full input surface, and `outputs.tf` / `outputs.tofu` for what is exposed.
