output "firewalls" {
  value = azurerm_firewall.firewall
}

output "public_ips" {
  value = azurerm_public_ip.public_ip
}
