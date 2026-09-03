resource "azurerm_network_interface" "network_interface" {
  for_each = var.virtual_machines

  name                = "${each.value.name}-nic"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "windows_virtual_machine" {
  for_each = var.virtual_machines

  name                = each.value.name
  computer_name       = try(each.value.computer_name, substr(replace(each.value.name, "-", ""), 0, 15))
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  network_interface_ids = [
    azurerm_network_interface.network_interface[each.key].id
  ]
  tags = each.value.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 32
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  dynamic "identity" {
    for_each = each.value.identity_ids != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = each.value.identity_ids
    }
  }
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  for_each = {
    for k, v in var.virtual_machines : k => v
    if v.install_kubectl == true || v.install_az_cli == true || v.install_tools == true
  }

  name                 = "${each.value.name}-tools-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_virtual_machine[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -Command \"${file("${path.module}/scripts/install_tools.ps1")}\""
  })
}
