variable "account_id" {
  description = "Cloudflare account ID. Used for every widget unless one overrides it."
  type        = string
}

variable "widgets" {
  description = <<-EOT
    Map of Turnstile widget objects to create. The map key is the widget name
    unless the object sets `name`.

    Per-widget keys mirror `cloudflare_turnstile_widget`: `name`, `domains`,
    `mode`, `account_id`, `bot_fight_mode`, `clearance_level`, `ephemeral_id`,
    `offlabel`, `region`.

    `region` cannot be changed after creation — changing it destroys and
    recreates the widget, which rotates the sitekey and breaks every page still
    embedding the old one.

    `bot_fight_mode`, `ephemeral_id`, and `offlabel` are Enterprise-only.
  EOT
  type        = any
}
