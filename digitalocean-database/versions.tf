terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"

      # `storage_autoscale` is not in every 2.x. Floor it where the block
      # exists rather than at 2.0, so a consumer that resolves an older
      # provider fails at init with a version constraint instead of at plan
      # with an unsupported block.
      version = ">= 2.99.0"
    }
  }
}
