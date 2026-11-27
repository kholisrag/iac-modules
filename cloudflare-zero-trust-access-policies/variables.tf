variable "account_id" {
  description = "Cloudflare account ID. Used for every policy unless one overrides it."
  type        = string
}

variable "policies" {
  description = <<-EOT
    Map of reusable Access policy objects to create. The map key is the policy
    name unless the object sets `name`, and it is the key of the `ids` output.

    Per-policy keys mirror `cloudflare_zero_trust_access_policy`:
    `name`, `account_id`, `decision` (required), `include`, `exclude`,
    `require`, `session_duration`, `approval_required`, `approval_groups`,
    `purpose_justification_required`, `purpose_justification_prompt`,
    `isolation_required`, `mfa_config`, `connection_rules`.

    `decision` is one of `allow`, `deny`, `non_identity` (the dashboard's
    Service Auth) or `bypass`.

    `include` is OR, `require` is AND, `exclude` is NOT. Each is a list of
    single-key rule objects, e.g. `{ email_domain = { domain = "example.com" } }`
    or `{ everyone = {} }`. A policy with no `include` matches nobody.

    A reusable policy carries NO `precedence`. Order belongs to the application
    that attaches it, as `policies = [{ id = ..., precedence = 1 }]`, so the
    same policy can sit first on one application and last on another.

    Reusable policies are account-level: there is no `zone_id`.
  EOT
  type        = any
  default     = {}

  validation {
    condition = alltrue([
      for policy in var.policies :
      contains(["allow", "deny", "non_identity", "bypass"], try(policy.decision, ""))
    ])
    error_message = "Every entry in `policies` must set `decision` to one of \"allow\", \"deny\", \"non_identity\" or \"bypass\"."
  }
}
