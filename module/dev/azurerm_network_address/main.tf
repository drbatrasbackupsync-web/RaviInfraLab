resource "azurerm_network_interface" "nic" {
  for_each = var.nic-chor-dev

  name                = each.value.nic_name
  location            = each.value.nic_location
  resource_group_name = each.value.nic_rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.data_subnet[each.key].id
    public_ip_address_id          = each.value.pip_name != null && each.value.pip_name != "" ? data.azurerm_public_ip.data_pip[each.key].id : null
    private_ip_address_allocation = "Dynamic"
  }
}

data "azurerm_public_ip" "data_pip" {
  for_each = { for k, v in var.nic-chor-dev : k => v if v.pip_name != null && v.pip_name != "" }

  name                = each.value.pip_name
  resource_group_name = each.value.nic_rg_name
}

data "azurerm_subnet" "data_subnet" {
  for_each = var.nic-chor-dev

  name                 = each.value.snet_name
  virtual_network_name = each.value.nic_vnet
  resource_group_name  = each.value.nic_rg_name
}