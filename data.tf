data "azurerm_client_config" "current" {}

data "azurerm_virtual_wan" "vwan" {
  name                = var.virtual_wan_name
  resource_group_name = var.virtual_wan_resource_group_name
}

data "azurerm_firewall_policy" "firewall_policy" {
  name                = var.firewall.policy_name
  resource_group_name = var.firewall.policy_resource_group_name
}

data "azurerm_log_analytics_workspace" "logs" {
  provider            = azurerm.logs
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}
