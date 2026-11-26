# cloudflare-zero-trust-device-managed-networks

OpenTofu module for `cloudflare zero trust device managed networks (TLS-endpoint network locations)`.

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
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-device-managed-networks/v0.1.0"
}
```

### OpenTofu / Terraform

```hcl
module "cloudflare_zero_trust_device_managed_networks" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=cloudflare-zero-trust-device-managed-networks/v0.1.0"
}
```

Floating tags `cloudflare-zero-trust-device-managed-networks/v0` and `cloudflare-zero-trust-device-managed-networks/v0.1` track the latest matching release.

## Things that bite

**The endpoint must be unreachable from outside the location** — including
through your own tunnel. The client auto-excludes a private-IP endpoint from
the tunnel, which is why `tls_sockaddr` must be an IP and not a hostname.

**An endpoint inside an Include-mode Split Tunnel entry excludes the WHOLE
entry.** If `10.0.0.0/8` is included and the endpoint is `10.0.0.1`, every
`10.x` address stops going through the tunnel. Carve the endpoint out of the
included range in the profiles that include it.

**Only one managed network should be reachable at a time.** With two
reachable, the client cannot pick a profile reliably.

**Detection times out after 5 seconds with no retry** and falls back to the
default profile. Verify with `warp-cli debug alternate-network`.

**Self-signed certs need `sha256`,** and the certificate needs both a `CN` and
a `subjectAltName`. The server must offer a cipher suite Rustls supports.
