output "private_endpoints" {
  value = azurerm_private_endpoint.private_endpoint
}

output "private_dns_zones" {
  value = azurerm_private_dns_zone.private_dns_zone
}
