# Root Module Orchestrator for Dev Environment

module "resource_group" {
  source = "./azurerm_resource_group"
}

module "virtual_network" {
  source     = "./azurerm_virtual_network"
  depends_on = [module.resource_group]
}

module "subnet" {
  source     = "./azurerm_subnet"
  depends_on = [module.virtual_network]
}

module "public_ip" {
  source     = "./azurerm_public_ip"
  depends_on = [module.resource_group]
}

module "network_interface" {
  source     = "./azurerm_network_address"
  depends_on = [module.subnet, module.public_ip]
}

module "nat_gateway" {
  source     = "./azurerm_nat_gateway"
  depends_on = [module.subnet, module.public_ip]
}

module "bastion" {
  source     = "./azurerm_bastion"
  depends_on = [module.subnet, module.public_ip]
}

module "app_gateway" {
  source     = "./azurerm_app_gateway"
  depends_on = [module.subnet, module.public_ip]
}

module "virtual_machine" {
  source     = "./azurerm_virtual_machine"
  depends_on = [module.network_interface]
}
