resource "azurerm_bastion_host" "bastion" {
  for_each            = var.bastion_config
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = data.azurerm_subnet.bastion_subnet[each.key].id
    public_ip_address_id = data.azurerm_public_ip.bastion_pip[each.key].id
  }
}

data "azurerm_subnet" "bastion_subnet" {
  for_each             = var.bastion_config
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "bastion_pip" {
  for_each            = var.bastion_config
  name                = each.value.public_ip_name
  resource_group_name = each.value.resource_group_name
}
