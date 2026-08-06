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

**The tunnel resource carries `prevent_destroy = true`, so `destroy` fails on
any stack that consumes this module.** That is deliberate. The module derives
`tunnel_id` from a tunnel it declares, so publishing routes on a tunnel that
already exists means adopting that tunnel — and nothing then tells the adopted
one apart from one you created. A tunnel is not recoverable by re-applying:
connector tokens and any WARP routes hang off its UUID.

**To remove a tunnel you genuinely own, take it out of state first**, then
delete it in the dashboard or wherever it is owned. `prevent_destroy` does not
block `state rm`. For an adopted tunnel this is the whole procedure and the
right one — it stops your stack managing the object without touching the object.

```bash
# Terragrunt, where this module is itself the root module
terragrunt state rm 'cloudflare_zero_trust_tunnel_cloudflared.tunnel["<key>"]'

# called as a child module
tofu state rm 'module.<name>.cloudflare_zero_trust_tunnel_cloudflared.tunnel["<key>"]'
```

**Do not do what the error message suggests.** OpenTofu's refusal ends with an
`-exclude=` for the tunnel, and running that destroys everything the guard does
*not* cover — including `cloudflare_zero_trust_tunnel_cloudflared_config`, the
tunnel's entire published-route list. It is an OpenTofu-only flag too, so it is
not even a portable mistake.

**Only the tunnel resource is guarded.** The config resource's contents are
declared in your own stack, so losing it costs an outage and an `apply` — and
guarding it would turn removing `ingress` from a tunnel's input map into a hard
error, since `config` instances are derived from that key being present.

See `variables.tf` for the full input surface, and `outputs.tf` for what is exposed.
