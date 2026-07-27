variable "app_gateway_config" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    vnet_name           = string
    subnet_name         = string
    public_ip_name      = string
  }))
}
