output "cloudflare_zone_output" {
  description = "Cloudflare Zone Outputs"
  value       = cloudflare_zone.zone
}

output "cloudflare_zone_setting_output" {
  description = "Cloudflare Zone Setting Outputs"
  value       = cloudflare_zone_setting.setting
}
