# digitalocean-database

OpenTofu module for DigitalOcean managed database clusters — the cluster, plus
optional databases, users, connection pools, a firewall and a read replica.

## Requirements

| Provider | Source | Version |
| --- | --- | --- |
| `digitalocean` | `digitalocean/digitalocean` | `>= 2.99.0` |

The floor is `2.99.0` rather than `2.0` because `storage_autoscale` is not in
every 2.x. A consumer resolving an older provider then fails at `init` on a
version constraint instead of at plan on an unsupported block.

Provider configuration is inherited from the consumer; this module declares no
`provider {}` block.

## Usage

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=digitalocean-database/v0.1.0"
}

inputs = {
  clusters = {
    db-pgsql-sgp1-example-prod = {
      engine     = "pg"
      version    = "18"
      size       = "db-amd-1vcpu-1gb"
      region     = "sgp1"
      node_count = 1

      project_id           = local.project_id
      private_network_uuid = dependency.vpc.outputs.digitalocean_vpc_ids["vpc-sgp1-example-prod"]

      storage_size_mib = 15 * 1024

      storage_autoscale = {
        enabled           = true
        threshold_percent = 95
        increment_gib     = 10
      }

      maintenance_window = {
        day  = "tuesday"
        hour = "18:00"
      }

      databases = ["app_production"]
      users     = [{ name = "app_production" }]
    }
  }
}
```

## Inputs

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `clusters` | Map of clusters. Key is the cluster name unless the object sets `name`. | `any` | `{}` |

Required per cluster: `engine`, `version`, `size`, `region`.

Optional: `node_count`, `project_id`, `private_network_uuid`, `tags`,
`storage_size_mib`, `eviction_policy`, `sql_mode`, `storage_autoscale`,
`maintenance_window`, `backup_restore`.

Child objects, each optional: `databases`, `users`, `connection_pools`,
`firewall_rules`, `replica`. See `variables.tf` for each one's shape.

## Outputs

| Name | Description | Sensitive |
| --- | --- | --- |
| `digitalocean_database_cluster_output` | Whole cluster objects | yes |
| `digitalocean_database_cluster_ids` | Cluster UUID by key | no |
| `digitalocean_database_cluster_urns` | Cluster URN by key | no |
| `digitalocean_database_cluster_endpoints` | host, private_host, port, database, user | no |
| `digitalocean_database_cluster_credentials` | password, uri, private_uri | yes |
| `digitalocean_database_db_output` | Database objects by `<cluster>/<db>` | no |
| `digitalocean_database_user_output` | User objects by `<cluster>/<user>` | yes |
| `digitalocean_database_connection_pool_output` | Pool objects by `<cluster>/<pool>` | yes |
| `digitalocean_database_firewall_output` | Firewall objects by cluster key | no |
| `digitalocean_database_replica_output` | Replica objects by cluster key | yes |

## What will bite you

**The cluster carries its own credentials as ordinary attributes.** `password`,
`uri` and `private_uri` are exported by the resource, so they are in state
whether or not anything reads them. **A stack consuming this module must
encrypt its state.** There is no argument to set a password — DigitalOcean
generates it — which is also why this module never holds one.

**`project_id` unset is not an error.** The cluster is filed under the
account's default project, bills there, and looks fine.

**A cluster with no `firewall_rules` gets no firewall resource at all.** That is
deliberate: `digitalocean_database_firewall` replaces the *whole* rule set for a
cluster, so an empty one is a deny-all applied by omission. Reach for
`private_network_uuid` first — the private endpoint is the control, and the
firewall is what narrows the public one.

**`storage_size_mib` is MiB and PostgreSQL/MySQL only.** Each size slug has its
own permitted range, and a value outside it is rejected at apply, not at plan.
Read the live ranges rather than the pricing page:

```bash
curl -sS -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  https://api.digitalocean.com/v2/databases/options | jq '.options.pg'
```

**`connection_pools` in `transaction` mode is PgBouncer**, which breaks
`LISTEN`/`NOTIFY` and any driver relying on session-scoped prepared statements —
`pgx` in its default mode among them. That is a property of the mode, not of
this module. Pick `session` if the client needs either.

**Changing `version` triggers a major-version upgrade**, not a replacement. It
is one-way.
