output "resource_group" {
  value = azurerm_resource_group.this.name
}
output "firewall_private_ip" {
  value = azurerm_firewall.this.ip_configuration[0].private_ip_address
}
output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}
