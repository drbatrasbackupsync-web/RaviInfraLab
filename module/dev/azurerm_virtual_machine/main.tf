resource "azurerm_linux_virtual_machine" "virtual_machine" {
  for_each = var.vm-chor-dev

  name                            = each.value.vm_name
  location                        = each.value.vm_location
  resource_group_name             = each.value.vm_rg_name
  size                            = each.value.vm_size
  admin_username                  = each.value.admin_user
  admin_password                  = each.value.admin_passwd
  disable_password_authentication = false

  network_interface_ids = [
    data.azurerm_network_interface.nic_data[each.key].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_network_interface" "nic_data" {
  for_each            = var.vm-chor-dev
  name                = each.value.nic_name
  resource_group_name = each.value.vm_rg_name
}