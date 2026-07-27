resource "azurerm_application_gateway" "appgw" {
  for_each            = var.app_gateway_config
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = data.azurerm_subnet.appgw_subnet[each.key].id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = data.azurerm_public_ip.appgw_pip[each.key].id
  }

  backend_address_pool {
    name = "appgw-backend-pool"
  }

  backend_http_settings {
    name                  = "http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule-http"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "http-setting"
    priority                   = 100
  }
}

data "azurerm_subnet" "appgw_subnet" {
  for_each             = var.app_gateway_config
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "appgw_pip" {
  for_each            = var.app_gateway_config
  name                = each.value.public_ip_name
  resource_group_name = each.value.resource_group_name
}
