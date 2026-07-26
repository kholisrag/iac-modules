output "cloudflare_r2_bucket_output" {
  description = "Cloudflare R2 Bucket Outputs"
  value       = cloudflare_r2_bucket.bucket
}

output "cloudflare_r2_bucket_lifecycle_output" {
  description = "Cloudflare R2 Bucket Lifecycle Outputs"
  value       = cloudflare_r2_bucket_lifecycle.lifecycle
}

output "cloudflare_r2_bucket_cors_output" {
  description = "Cloudflare R2 Bucket CORS Outputs"
  value       = cloudflare_r2_bucket_cors.cors
}

output "cloudflare_r2_bucket_lock_output" {
  description = "Cloudflare R2 Bucket Lock Outputs"
  value       = cloudflare_r2_bucket_lock.lock
}
