locals {
  name = var.project_name
  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
    Owner     = "Muhammad Ahmad"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "${local.name}-rg"
  location = var.location
  tags     = local.tags
}

############################
# Hub VNet
############################
resource "azurerm_virtual_network" "hub" {
  name                = "${local.name}-hub-vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/26"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/26"]
}

############################
# Spoke VNets
############################
resource "azurerm_virtual_network" "spoke1" {
  name                = "${local.name}-spoke1-vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  address_space       = ["10.1.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "spoke1" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_virtual_network" "spoke2" {
  name                = "${local.name}-spoke2-vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  address_space       = ["10.2.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "spoke2" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = ["10.2.0.0/24"]
}

############################
# VNet peering (hub <-> spokes)
############################
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "hub-to-spoke1"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke1.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                      = "spoke1-to-hub"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "hub-to-spoke2"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke2.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                      = "spoke2-to-hub"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

############################
# Azure Firewall (hub)
############################
resource "azurerm_public_ip" "firewall" {
  name                = "${local.name}-fw-pip"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_firewall" "this" {
  name                = "${local.name}-fw"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = local.tags
}

############################
# Azure Bastion (hub)
############################
resource "azurerm_public_ip" "bastion" {
  name                = "${local.name}-bastion-pip"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_bastion_host" "this" {
  name                = "${local.name}-bastion"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = local.tags
}

############################
# Route spokes through the firewall
############################
resource "azurerm_route_table" "spoke" {
  name                = "${local.name}-spoke-rt"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  route {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.this.ip_configuration[0].private_ip_address
  }

  tags = local.tags
}

resource "azurerm_subnet_route_table_association" "spoke1" {
  subnet_id      = azurerm_subnet.spoke1.id
  route_table_id = azurerm_route_table.spoke.id
}

resource "azurerm_subnet_route_table_association" "spoke2" {
  subnet_id      = azurerm_subnet.spoke2.id
  route_table_id = azurerm_route_table.spoke.id
}
