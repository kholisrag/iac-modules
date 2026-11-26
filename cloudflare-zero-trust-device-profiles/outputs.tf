output "cloudflare_zero_trust_device_default_profile_output" {
  description = "Cloudflare Zero Trust Device Default Profile Outputs. Carries Split Tunnel entries — treat as topology."
  value       = cloudflare_zero_trust_device_default_profile.default
}

output "cloudflare_zero_trust_device_custom_profile_output" {
  description = "Cloudflare Zero Trust Device Custom Profile Outputs. Carries Split Tunnel entries — treat as topology."
  value       = cloudflare_zero_trust_device_custom_profile.custom
}

output "custom_profile_ids" {
  description = "Per custom profile key, its `policy_id`."
  value = {
    for i, profile in cloudflare_zero_trust_device_custom_profile.custom : i => profile.policy_id
  }
}
