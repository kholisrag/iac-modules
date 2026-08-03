locals {
  clusters = {
    for i, cluster in var.clusters : i => merge(
      {
        name = i
      },
      cluster
    )
  }

  # One entry per (cluster, child). The child's own attributes are read back out
  # of `local.clusters` at resource time rather than carried through the
  # flatten: a `users` entry and a `pools` entry have different shapes, and
  # HCL would have to unify them if both travelled in one flattened list.
  databases = {
    for pair in flatten([
      for cluster_key, cluster in local.clusters : [
        for db_name in lookup(cluster, "databases", []) : {
          key         = "${cluster_key}/${db_name}"
          cluster_key = cluster_key
          name        = db_name
        }
      ]
    ]) : pair.key => pair
  }

  users = {
    for pair in flatten([
      for cluster_key, cluster in local.clusters : [
        for user in lookup(cluster, "users", []) : {
          key         = "${cluster_key}/${user.name}"
          cluster_key = cluster_key
          user        = user
        }
      ]
    ]) : pair.key => pair
  }

  connection_pools = {
    for pair in flatten([
      for cluster_key, cluster in local.clusters : [
        for pool in lookup(cluster, "connection_pools", []) : {
          key         = "${cluster_key}/${pool.name}"
          cluster_key = cluster_key
          pool        = pool
        }
      ]
    ]) : pair.key => pair
  }

  # A firewall is a singleton per cluster and REPLACES the whole rule set, so
  # a cluster that names no rules must not get an empty one — that would be a
  # deny-all applied by omission.
  firewalled_clusters = {
    for i, cluster in local.clusters : i => cluster
    if length(lookup(cluster, "firewall_rules", [])) > 0
  }

  replica_clusters = {
    for i, cluster in local.clusters : i => cluster
    if lookup(cluster, "replica", null) != null
  }
}

resource "digitalocean_database_cluster" "cluster" {
  for_each = local.clusters

  name       = each.value.name
  engine     = each.value.engine
  version    = each.value.version
  size       = each.value.size
  region     = each.value.region
  node_count = lookup(each.value, "node_count", 1)

  # Unset assigns the cluster to the account's DEFAULT project, which is a
  # silent outcome rather than an error — the cluster exists, bills, and is
  # filed under whichever project happens to carry the flag.
  project_id = lookup(each.value, "project_id", null)

  # The VPC. Unset puts the cluster on the region's default VPC, and moving it
  # afterwards is an in-place update the provider supports — but the private
  # hostname changes with it, so every consumer's DSN does too.
  private_network_uuid = lookup(each.value, "private_network_uuid", null)

  tags = lookup(each.value, "tags", null)

  # Engine-specific, and each is silently ignored by the others.
  eviction_policy = lookup(each.value, "eviction_policy", null)
  sql_mode        = lookup(each.value, "sql_mode", null)

  # MiB, not GiB, and only MySQL and PostgreSQL accept it. Each size slug has
  # its own permitted range; a value outside it is rejected at apply, not plan.
  storage_size_mib = lookup(each.value, "storage_size_mib", null)

  dynamic "storage_autoscale" {
    for_each = lookup(each.value, "storage_autoscale", null) != null ? [each.value.storage_autoscale] : []

    content {
      enabled           = storage_autoscale.value.enabled
      threshold_percent = lookup(storage_autoscale.value, "threshold_percent", null)
      increment_gib     = lookup(storage_autoscale.value, "increment_gib", null)
    }
  }

  dynamic "maintenance_window" {
    for_each = lookup(each.value, "maintenance_window", null) != null ? [each.value.maintenance_window] : []

    content {
      day  = maintenance_window.value.day
      hour = maintenance_window.value.hour
    }
  }

  # Fork of an existing cluster's backup. Naming a cluster that does not exist
  # fails at apply; leaving this set after the fork has been taken does not
  # re-fork, because the block only participates in creation.
  dynamic "backup_restore" {
    for_each = lookup(each.value, "backup_restore", null) != null ? [each.value.backup_restore] : []

    content {
      database_name     = backup_restore.value.database_name
      backup_created_at = lookup(backup_restore.value, "backup_created_at", null)
    }
  }
}

resource "digitalocean_database_db" "database" {
  for_each = local.databases

  cluster_id = digitalocean_database_cluster.cluster[each.value.cluster_key].id
  name       = each.value.name
}

resource "digitalocean_database_user" "user" {
  for_each = local.users

  cluster_id = digitalocean_database_cluster.cluster[each.value.cluster_key].id
  name       = each.value.user.name

  # MySQL only. The password is DigitalOcean's to generate either way — there
  # is no argument to set one, which is why this module never holds a password
  # and a consumer reads it out of the (encrypted) state or the dashboard.
  mysql_auth_plugin = lookup(each.value.user, "mysql_auth_plugin", null)
}

resource "digitalocean_database_connection_pool" "connection_pool" {
  for_each = local.connection_pools

  cluster_id = digitalocean_database_cluster.cluster[each.value.cluster_key].id
  name       = each.value.pool.name
  mode       = each.value.pool.mode
  size       = each.value.pool.size
  db_name    = each.value.pool.db_name
  user       = lookup(each.value.pool, "user", null)

  # `transaction` mode is PgBouncer's, and it breaks both LISTEN/NOTIFY and
  # any driver that relies on session-scoped prepared statements. That is a
  # property of the mode, not of this module — pick `session` if the client
  # needs either.
  depends_on = [digitalocean_database_db.database]
}

resource "digitalocean_database_firewall" "firewall" {
  for_each = local.firewalled_clusters

  cluster_id = digitalocean_database_cluster.cluster[each.key].id

  dynamic "rule" {
    for_each = each.value.firewall_rules

    content {
      type  = rule.value.type
      value = rule.value.value
    }
  }
}

resource "digitalocean_database_replica" "replica" {
  for_each = local.replica_clusters

  cluster_id = digitalocean_database_cluster.cluster[each.key].id
  name       = each.value.replica.name
  size       = lookup(each.value.replica, "size", each.value.size)
  region     = lookup(each.value.replica, "region", each.value.region)

  private_network_uuid = lookup(each.value.replica, "private_network_uuid", lookup(each.value, "private_network_uuid", null))
  storage_size_mib     = lookup(each.value.replica, "storage_size_mib", null)
  tags                 = lookup(each.value.replica, "tags", null)
}
