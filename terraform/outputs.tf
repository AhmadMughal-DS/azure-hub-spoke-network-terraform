output "resource_group" {
  description = "Resource group name"
  value       = azurerm_resource_group.this.name
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP (spoke default route target)"
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = azurerm_virtual_network.hub.id
}
