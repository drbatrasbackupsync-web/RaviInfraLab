resource "azurerm_nat_gateway" "natgw" {
  for_each            = var.nat_gateway_config
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "natgw_pip_assoc" {
  for_each             = var.nat_gateway_config
  nat_gateway_id       = azurerm_nat_gateway.natgw[each.key].id
  public_ip_address_id = data.azurerm_public_ip.natgw_pip[each.key].id
}

resource "azurerm_subnet_nat_gateway_association" "natgw_subnet_assoc" {
  for_each       = var.nat_gateway_config
  subnet_id      = data.azurerm_subnet.backend_subnet[each.key].id
  nat_gateway_id = azurerm_nat_gateway.natgw[each.key].id
}

data "azurerm_subnet" "backend_subnet" {
  for_each             = var.nat_gateway_config
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "natgw_pip" {
  for_each            = var.nat_gateway_config
  name                = each.value.public_ip_name
  resource_group_name = each.value.resource_group_name
}
