resource "proxmox_virtual_environment_hardware_mapping_pci" "hardware_mapping_pci" {
  name             = var.hardware_mapping_pci.name
  comment          = lookup(var.hardware_mapping_pci, "comment", null)
  mediated_devices = lookup(var.hardware_mapping_pci, "mediated_devices", null)

  # `map` is a required set-typed attribute (not a block) in bpg/proxmox.
  map = [
    for entry in lookup(var.hardware_mapping_pci, "map", []) : {
      id           = entry.id
      node         = entry.node
      path         = entry.path
      comment      = lookup(entry, "comment", null)
      iommu_group  = lookup(entry, "iommu_group", null)
      subsystem_id = lookup(entry, "subsystem_id", null)
    }
  ]
}
