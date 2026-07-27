resource "azurerm_resource_group" "resource_group" {
  for_each = var.rg-chor-dev

  name     = each.value.name
  location = each.value.location
}
