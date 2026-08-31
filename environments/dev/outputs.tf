output "dev_infrastructure" {
  description = "Dev environment resources summary"
  value = {
    resource_groups = module.resource_groups.resource_groups
    vnets           = module.vnets.vnets
    acrs            = module.acrs.registries
    aks_clusters    = module.aks.clusters
    key_vaults      = module.key_vaults.vaults
    apim_services   = module.apim.apim_services
  }
  sensitive = true
}
