resource "proxmox_virtual_environment_hardware_mapping_usb" "hardware_mapping_usb" {
  name    = var.hardware_mapping_usb.name
  comment = lookup(var.hardware_mapping_usb, "comment", null)

  # `map` is a required set-typed attribute (not a block) in bpg/proxmox.
  map = [
    for entry in lookup(var.hardware_mapping_usb, "map", []) : {
      id      = entry.id
      node    = entry.node
      path    = lookup(entry, "path", null)
      comment = lookup(entry, "comment", null)
    }
  ]
}
