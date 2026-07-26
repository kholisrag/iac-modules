# cloudflare-r2-buckets

OpenTofu module for `cloudflare r2 bucket` resources, with optional lifecycle,
CORS, and object-lock rules per bucket.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-r2-buckets/v0.1.0"
}

inputs = {
  account_id = local.account_id

  buckets = {
    my-bucket = {
      location      = "apac"
      storage_class = "Standard"

      lifecycle_rules = [
        {
          id         = "abort-stale-multipart-uploads"
          enabled    = true
          conditions = { prefix = "" }
          abort_multipart_uploads_transition = {
            condition = { type = "Age", max_age = 604800 }
          }
        },
      ]
    }
  }
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_r2_buckets" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-r2-buckets/v0.1.0"
}
```

Floating tags `cloudflare-r2-buckets/v0` and `cloudflare-r2-buckets/v0.1` track the latest matching release.

## Things that bite

**`location` is first-creation only.** Cloudflare honours it when the bucket
name is first used and ignores it forever after. Delete and recreate a bucket
with the same name and it returns to its original location — with no error and
no diff. It is also best-effort, not a guarantee.

**Lifecycle, CORS, and lock own the whole rule list.** Each is a singleton
resource per bucket, not a per-rule resource. Dropping a rule from the list
deletes it; rules added in the dashboard are removed on the next apply.

**Do not put a lock rule on a bucket holding OpenTofu state.** Object lock
refuses to delete or overwrite objects younger than its condition, and a state
file is overwritten on every single apply. The lock will take effect exactly
when you least want it to.

**`max_age` is in seconds**, not days — the API field is an age in seconds even
though the dashboard presents days.

**Neither lifecycle, CORS, nor lock supports `terraform import`.** Rules created
by hand must be deleted by hand before the first apply, or the apply fights
them.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
