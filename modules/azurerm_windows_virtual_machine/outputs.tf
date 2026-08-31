output "virtual_machines" {
  value     = azurerm_windows_virtual_machine.windows_virtual_machine
  sensitive = true
}
