locals {
  buckets = {
    for i, bucket in var.buckets : i => merge(
      {
        name       = i
        account_id = var.account_id
      },
      bucket
    )
  }

  # Lifecycle, CORS, and lock are separate API surfaces, each a singleton per
  # bucket. Selecting only the buckets that ask for one keeps an untouched
  # bucket free of an empty-rule resource that would fight the dashboard.
  lifecycle_buckets = {
    for i, bucket in local.buckets : i => bucket
    if length(lookup(bucket, "lifecycle_rules", [])) > 0
  }

  cors_buckets = {
    for i, bucket in local.buckets : i => bucket
    if length(lookup(bucket, "cors_rules", [])) > 0
  }

  lock_buckets = {
    for i, bucket in local.buckets : i => bucket
    if length(lookup(bucket, "lock_rules", [])) > 0
  }
}

resource "cloudflare_r2_bucket" "bucket" {
  for_each = local.buckets

  account_id = each.value.account_id
  name       = each.value.name

  # `location` is honoured only on first creation. Recreating a bucket with a
  # name that has existed before reuses the original location, silently — so a
  # location change here is not a change at all until the name changes too.
  location      = lookup(each.value, "location", null)
  storage_class = lookup(each.value, "storage_class", null)
  jurisdiction  = lookup(each.value, "jurisdiction", null)
}

resource "cloudflare_r2_bucket_lifecycle" "lifecycle" {
  for_each = local.lifecycle_buckets

  account_id   = each.value.account_id
  bucket_name  = cloudflare_r2_bucket.bucket[each.key].name
  jurisdiction = lookup(each.value, "jurisdiction", null)

  rules = each.value.lifecycle_rules
}

resource "cloudflare_r2_bucket_cors" "cors" {
  for_each = local.cors_buckets

  account_id   = each.value.account_id
  bucket_name  = cloudflare_r2_bucket.bucket[each.key].name
  jurisdiction = lookup(each.value, "jurisdiction", null)

  rules = each.value.cors_rules
}

resource "cloudflare_r2_bucket_lock" "lock" {
  for_each = local.lock_buckets

  account_id   = each.value.account_id
  bucket_name  = cloudflare_r2_bucket.bucket[each.key].name
  jurisdiction = lookup(each.value, "jurisdiction", null)

  rules = each.value.lock_rules
}
