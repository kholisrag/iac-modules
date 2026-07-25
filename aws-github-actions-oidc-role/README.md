# aws-github-actions-oidc-role

Wrapper around the upstream `voquis/github-actions-oidc-role/aws` module pinned at `0.0.5`.

Migrated from `kholisrag/labirin` `modules/opentofu/aws/github-actions-oidc-role/0.0.5`.

## Usage

Releases are cut per module by release-please. Each release publishes an orphan tag
whose root **is** this module, so no `//<subdir>` selector is needed:

### Terragrunt

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=aws-github-actions-oidc-role/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "aws_github_actions_oidc_role" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=aws-github-actions-oidc-role/v0.1.0"
}
```

Floating tags `aws-github-actions-oidc-role/v0` and `aws-github-actions-oidc-role/v0.1` track the latest matching release.

See `variables.tf` / `variables.tofu` for the full input surface, and `outputs.tf` / `outputs.tofu` for what is exposed.
