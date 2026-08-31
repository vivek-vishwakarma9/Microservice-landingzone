output "function_apps" {
  value     = azurerm_linux_function_app.linux_function_app
  sensitive = true
}
