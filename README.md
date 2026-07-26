# cloudflare-tunnel

OpenTofu module for `cloudflare zero trust cloudflared tunnel resources`.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-tunnel/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_tunnel" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-tunnel/v0.1.0"
}
```

Floating tags `cloudflare-tunnel/v0` and `cloudflare-tunnel/v0.1` track the latest matching release.

## Things that bite

**The last ingress rule must be a catch-all** — no `hostname`, usually
`service = "http_status:404"`. The API rejects a config without one. This module
does not append it for you, because a hidden default here would be a hidden
route.

**A healthy tunnel proves nothing about reachability.** It proves `cloudflared`
reached Cloudflare. Traffic also needs an ingress rule *and* a DNS record
pointing at `<tunnel-id>.cfargotunnel.com` — see the `tunnel_cname` output.

**`ingress` only applies when `config_src = "cloudflare"`.** A `local` tunnel
reads rules from a YAML file on the origin machine and ignores anything declared
here, silently.

**`tunnel_token` is full authority to serve traffic for the tunnel**, and it
lives in state. Encrypt the state of any stack that consumes this module.

**`tunnel_secret` is for locally-managed tunnels only** and must be at least 32
bytes, base64-encoded.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
