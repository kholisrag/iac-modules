# cloudflare-zero-trust-service-tokens

OpenTofu module for `cloudflare zero trust access service token resources`.

A service token is a non-human credential — a Client ID / Client Secret pair a
machine sends to get past Cloudflare Access. Applications and their policies
live in [`cloudflare-zero-trust-access`](../cloudflare-zero-trust-access); this
module only mints the tokens those policies reference.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-service-tokens/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_zero_trust_service_tokens" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-service-tokens/v0.1.0"

  account_id = var.account_id

  service_tokens = {
    ci = {
      duration = "720h"
    }
  }
}
```

Floating tags `cloudflare-zero-trust-service-tokens/v0` and `cloudflare-zero-trust-service-tokens/v0.1` track the latest matching release.

## Why this is its own module

A Service Auth policy references a token by **ID**, and in the v5 provider
policies are declared inline on the application. `cloudflare-zero-trust-access`
takes those policies verbatim from its caller, as opaque values inside
`var.applications` — so the token ID reaches the policy as a module *input*:

```hcl
module "service_tokens" {
  source = "…?ref=cloudflare-zero-trust-service-tokens/v0.1.0"
  # …
}

module "access" {
  source = "…?ref=cloudflare-zero-trust-access/v0.1.0"

  applications = {
    api = {
      policies = [{
        decision = "non_identity"
        include = [{
          service_token = {
            token_id = module.service_tokens.token_ids["ci"] # ← the other module
          }
        }]
      }]
    }
  }
}
```

Put the token resource inside the access module and that reference becomes
`module.access.token_ids[...]` fed back into `module.access` — a self-referential
module call OpenTofu rejects as a cycle. The caller cannot reach past the module
boundary to name the resource directly, so the only way out is for the access
module to stop passing `policies` through and start *building* them from some
token-key convention of its own — a larger, lossier input surface than the
provider's, to solve a problem two modules do not have.

Keeping them apart also keeps a **secret-bearing** resource out of a module
whose outputs are all non-sensitive today, and decouples the release cadence:
rotating a token should not bump the version every consumer of Access
*applications* tracks.

## Wiring a Service Auth policy

Three things have to line up, and getting two of them right fails closed:

1. **The policy decision must be `non_identity`.** That is the API name for the
   dashboard's **Service Auth** action. With `allow` instead, Access prompts for
   an identity provider login and the token never gets a chance to match.
2. **The include rule is `service_token`, keyed by `token_id`** — the resource
   ID from this module's `token_ids` output. Not the `client_id`.
3. **The caller sends both headers**, `CF-Access-Client-Id` and
   `CF-Access-Client-Secret`, from `client_ids` and `client_secrets`.

Against [`cloudflare-zero-trust-access`](../cloudflare-zero-trust-access):

```hcl
policies = [{
  name       = "ci service auth"
  decision   = "non_identity"
  precedence = 1
  include = [{
    service_token = {
      token_id = module.service_tokens.token_ids["ci"]
    }
  }]
}]
```

`any_valid_service_token = {}` also exists and matches **every** service token in
the account. It is the wrong default: it turns each new token minted anywhere in
the account into an extra key for this application, and nothing reports that.
Name the token.

## Never put a Service Auth policy on an admin application

**An administrative application — a console, a fleet or abuse dashboard, anything
whose whole reason for sitting behind Access is that reaching it requires a human
identity check — takes no Service Auth policy at all. Identity-only, no
exceptions.**

A service token is a bearer credential held by a machine. Attaching one to an
admin application promotes every process holding that token to operator, and it
does so silently: the application looks unchanged, the policy list grows by one
line, and the identity check the application does not perform itself is now
skippable. A token that is shared across a project — which is the usual reason to
have one at all — makes that reach as wide as the project.

Scope service tokens to the machine-to-machine applications that need them, and
leave the admin surface to identity.

## Things that bite

**`duration` is required here and optional in the provider.** The provider
defaults to `8760h` — a year. This module refuses to pick that for you, because
the default is invisible in the config and the expiry arrives as an outage.
`duration = "8760h"` is a fine answer; not saying anything is not.

**Nothing renews a token.** `expires_at` is fixed at creation from `duration`.
Rotation is manual and deliberate: bump `client_secret_version`, redeploy
whatever holds the secret, then let `previous_client_secret_expires_at` pass.
Both secrets work in that window.

**`client_secret` is in state and nowhere else.** Cloudflare does not display it
again after creation, so the state file is the copy of record. Encrypt the state
of any stack consuming this module.

**A Service-Auth-only application has no usable JWT.** If an application's only
policies are Service Auth, every request must carry the token headers — the
`CF_Authorization` cookie is only issued when the application also has at least
one Allow policy.

**`account_id` and `zone_id` are mutually exclusive.** This module defaults
`account_id` from `var.account_id`, so a zone-scoped token must set `zone_id`
*and* `account_id = null` explicitly.

**A token is a reachability gate, not an authorization model.** It gets a request
past Access. What the request is then allowed to do is the origin's problem, and
Access will not answer it.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
