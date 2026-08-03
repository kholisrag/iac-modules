output "digitalocean_database_cluster_output" {
  description = <<-EOT
    Cluster objects keyed by the input map's key.

    SENSITIVE IN WHOLE. `digitalocean_database_cluster` exports `password`,
    `uri` and `private_uri` as ordinary attributes, so there is no non-secret
    subset of this object — marking only the nested fields is not something
    the language offers here.
  EOT
  value       = digitalocean_database_cluster.cluster
  sensitive   = true
}

output "digitalocean_database_cluster_ids" {
  description = "Cluster UUID by input map key."
  value       = { for k, v in digitalocean_database_cluster.cluster : k => v.id }
}

output "digitalocean_database_cluster_urns" {
  description = "Cluster URN by input map key, for project resource assignment."
  value       = { for k, v in digitalocean_database_cluster.cluster : k => v.urn }
}

output "digitalocean_database_cluster_endpoints" {
  description = <<-EOT
    The non-secret half of each cluster's connection details: public host,
    private host, port, default database name and default user name.

    `private_host` is the one to use from inside the VPC. It resolves only for
    resources on the same account in the same region, which is what keeps the
    cluster's traffic off the public endpoint without relying on the firewall
    to be right.
  EOT
  value = {
    for k, v in digitalocean_database_cluster.cluster : k => {
      host         = v.host
      private_host = v.private_host
      port         = v.port
      database     = v.database
      user         = v.user
    }
  }
}

output "digitalocean_database_cluster_credentials" {
  description = <<-EOT
    Default user's password and both URIs, by input map key.

    The provider is the only place these exist in a form anything can read
    without a dashboard visit, so a stack consuming this module MUST encrypt
    its state.
  EOT
  value = {
    for k, v in digitalocean_database_cluster.cluster : k => {
      password    = v.password
      uri         = v.uri
      private_uri = v.private_uri
    }
  }
  sensitive = true
}

output "digitalocean_database_db_output" {
  description = "Database objects keyed by `<cluster key>/<database name>`."
  value       = digitalocean_database_db.database
}

output "digitalocean_database_user_output" {
  description = "User objects keyed by `<cluster key>/<user name>`. Carries each user's generated password."
  value       = digitalocean_database_user.user
  sensitive   = true
}

output "digitalocean_database_connection_pool_output" {
  description = "Connection pool objects keyed by `<cluster key>/<pool name>`. Carries the pool's URI."
  value       = digitalocean_database_connection_pool.connection_pool
  sensitive   = true
}

output "digitalocean_database_firewall_output" {
  description = "Firewall objects for the clusters that named rules, keyed by cluster key."
  value       = digitalocean_database_firewall.firewall
}

output "digitalocean_database_replica_output" {
  description = "Replica objects for the clusters that asked for one, keyed by cluster key. Carries the replica's credentials."
  value       = digitalocean_database_replica.replica
  sensitive   = true
}
