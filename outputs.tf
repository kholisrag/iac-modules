output "cloudflare_zero_trust_access_policy_output" {
  description = "Cloudflare Zero Trust Access Policy Outputs, whole resources by map key."
  value       = cloudflare_zero_trust_access_policy.policy
}

output "ids" {
  description = <<-EOT
    Per policy, its ID, by map key. This is what an application references as
    `policies = [{ id = ..., precedence = 1 }]`.
  EOT
  value = {
    for i, policy in cloudflare_zero_trust_access_policy.policy : i => policy.id
  }
}
