# digitalocean-vpc

OpenTofu module for `digitalocean_vpc` resources.

A VPC is **regional**. Resources in another region cannot join it, and there is
no peering — so one VPC per region per environment, not one per account.

## Requirements

| Provider | Source | Version |
| --- | --- | --- |
| `digitalocean` | `digitalocean/digitalocean` | `>= 2.99.0` |

Provider configuration is inherited from the consumer; this module declares no
`provider {}` block.

## Usage

Releases are cut per module by release-please. Each release publishes an orphan
tag whose root **is** this module, so no `//<subdir>` selector is needed:

### Terragrunt

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=digitalocean-vpc/v0.1.0"
}

inputs = {
  vpcs = {
    vpc-sgp1-example-prod = {
      region      = "sgp1"
      description = "Production, Singapore"
      ip_range    = "10.140.0.0/20"
    }
  }
}
```

### OpenTofu

```hcl
module "vpc" {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=digitalocean-vpc/v0.1.0"

  vpcs = {
    vpc-sgp1-example-prod = {
      region   = "sgp1"
      ip_range = "10.140.0.0/20"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `vpcs` | Map of VPCs. Key is the name unless the object sets `name`. | `any` | `{}` |

Per-VPC keys: `region` (required), `description`, `ip_range`.

## Outputs

| Name | Description |
| --- | --- |
| `digitalocean_vpc_output` | Whole VPC objects, keyed by input map key |
| `digitalocean_vpc_ids` | VPC UUID by key — what `private_network_uuid` / `vpc_uuid` want |
| `digitalocean_vpc_urns` | VPC URN by key, for project resource assignment |

## Two traps

**`ip_range` is decided once.** Omitting it lets DigitalOcean allocate a range;
adding one later is a **replacement**, and every database cluster, Droplet and
load balancer assigned to the VPC has to be moved out first. Set it at creation.

**The account already has a default VPC in every region it has ever used**, and
ranges must not overlap. List them before choosing:

```bash
doctl vpcs list
# or
curl -sS -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  https://api.digitalocean.com/v2/vpcs | jq -r '.vpcs[] | "\(.region) \(.name) \(.ip_range) default=\(.default)"'
```

The range may not be larger than `/16` nor smaller than `/24`, and must be
inside RFC1918.
