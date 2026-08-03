variable "clusters" {
  description = <<-EOT
    Map of DigitalOcean managed database clusters. The map key is the cluster
    name unless the object sets `name`.

    Required per cluster, mirroring `digitalocean_database_cluster`:

      - `engine`  — `pg`, `mysql`, `mongodb`, `valkey`, `kafka`, `opensearch`
      - `version` — engine major version as a string, e.g. `"18"`
      - `size`    — size slug, e.g. `db-s-1vcpu-1gb` (regular),
                    `db-amd-1vcpu-1gb` / `db-intel-1vcpu-1gb` (premium)
      - `region`  — region slug

    Optional:

      - `node_count`           — 1 unless set; Kafka requires 3
      - `project_id`           — UNSET FILES THE CLUSTER UNDER THE ACCOUNT'S
                                 DEFAULT PROJECT, silently
      - `private_network_uuid` — the VPC; unset means the region's default VPC
      - `tags`                 — list of tag names
      - `storage_size_mib`     — MiB, MySQL and PostgreSQL only, and each size
                                 slug has its own permitted range
      - `eviction_policy`      — Valkey only
      - `sql_mode`             — MySQL only
      - `storage_autoscale`    — `{ enabled, threshold_percent, increment_gib }`
      - `maintenance_window`   — `{ day, hour }`, hour as `"13:00"` UTC
      - `backup_restore`       — `{ database_name, backup_created_at }`, read
                                 only at creation

    Child objects, each optional:

      - `databases`        — list of database names
      - `users`            — list of `{ name, mysql_auth_plugin }`
      - `connection_pools` — list of `{ name, mode, size, db_name, user }`.
                             `transaction` mode is PgBouncer and breaks
                             LISTEN/NOTIFY and session-scoped prepared
                             statements
      - `firewall_rules`   — list of `{ type, value }`. A cluster that names
                             NONE gets no firewall resource at all, because a
                             firewall replaces the whole rule set and an empty
                             one is a deny-all applied by omission
      - `replica`          — `{ name, size, region, private_network_uuid,
                             storage_size_mib, tags }`; `size` and `region`
                             fall back to the primary's

    Passwords are DigitalOcean's to generate and there is no argument to set
    one, so this module never carries a credential. A consumer reads
    `digitalocean_database_cluster_credentials` out of state, which must
    therefore be encrypted.
  EOT
  type        = any
  default     = {}
}
