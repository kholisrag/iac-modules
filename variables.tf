variable "account_id" {
  description = "Cloudflare account ID. Used for every bucket unless one overrides it."
  type        = string
}

variable "buckets" {
  description = <<-EOT
    Map of R2 bucket objects to create. The map key is the bucket name unless the
    object sets `name`.

    Per-bucket keys mirror `cloudflare_r2_bucket`: `name`, `account_id`,
    `location`, `storage_class`, `jurisdiction`.

    Three optional lists attach subresources to the bucket. Each is a separate
    Cloudflare resource, so an empty or absent list creates nothing:

      lifecycle_rules  -> cloudflare_r2_bucket_lifecycle.rules
      cors_rules       -> cloudflare_r2_bucket_cors.rules
      lock_rules       -> cloudflare_r2_bucket_lock.rules

    Note that lifecycle, CORS, and lock are singleton resources per bucket that
    own the *whole* rule list. Passing a shorter list removes the rules you left
    out — they do not merge.
  EOT
  type        = any
}
