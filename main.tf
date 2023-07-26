resource "azurerm_virtual_hub" "vhub" {
  name                   = var.virtual_hub_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  virtual_wan_id         = data.azurerm_virtual_wan.vwan.id
  address_prefix         = var.address_prefix
  hub_routing_preference = var.hub_routing_preference
  sku                    = var.sku

  dynamic "route" {
    for_each = { for k in var.routes : k.name => k if k != null }

    content {
      address_prefixes    = route.address_prefixes
      next_hop_ip_address = route.next_hop_ip_address
    }
  }

  tags = var.tags
}

resource "azurerm_vpn_server_configuration" "vpn_config" {
  count                    = var.p2s_vpn == null ? 0 : 1
  name                     = var.p2s_vpn.vpn_server_configuration_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  vpn_authentication_types = var.p2s_vpn.vpn_authentication_types
  vpn_protocols            = var.p2s_vpn.vpn_protocols


  dynamic "ipsec_policy" {
    for_each = var.p2s_vpn.ipsec_policy == null ? [] : [var.p2s_vpn.ipsec_policy]

    content {
      dh_group               = ipsec_policy.value["dh_group"]
      ike_encryption         = ipsec_policy.value["ike_encryption"]
      ike_integrity          = ipsec_policy.value["ike_integrity"]
      ipsec_encryption       = ipsec_policy.value["ipsec_encryption"]
      ipsec_integrity        = ipsec_policy.value["ipsec_integrity"]
      pfs_group              = ipsec_policy.value["pfs_group"]
      sa_lifetime_seconds    = ipsec_policy.value["sa_lifetime_seconds"]
      sa_data_size_kilobytes = ipsec_policy.value["sa_data_size_kilobytes"]
    }
  }

  dynamic "azure_active_directory_authentication" {
    for_each = contains(var.p2s_vpn.vpn_authentication_types, "AAD") == true ? [var.p2s_vpn.azure_active_directory_authentication] : []
    content {
      audience = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
      issuer   = azure_active_directory_authentication.value["app_id"]
      tenant   = data.azurerm_client_config.current.tenant_id
    }
  }

  dynamic "client_root_certificate" {
    for_each = { for k in var.p2s_vpn.client_root_certificates : k.name => k if k != null }

    content {
      name             = client_root_certificate.key
      public_cert_data = client_root_certificate.value["public_cert_data"]
    }
  }

  dynamic "client_revoked_certificate" {
    for_each = { for k in var.p2s_vpn.client_revoked_certificates : k.name => k if k != null }

    content {
      name       = client_revoked_certificate.key
      thumbprint = client_revoked_certificate.value["thumbprint"]
    }
  }

  tags = var.tags
}

resource "azurerm_point_to_site_vpn_gateway" "p2sgw" {
  count                               = var.p2s_vpn == null ? 0 : 1
  name                                = var.p2s_vpn.vpn_gateway_name
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  virtual_hub_id                      = azurerm_virtual_hub.vhub.id
  vpn_server_configuration_id         = azurerm_vpn_server_configuration.vpn_config[0].id
  scale_unit                          = var.p2s_vpn.scale_unit
  dns_servers                         = var.p2s_vpn.dns_servers
  routing_preference_internet_enabled = var.p2s_vpn.routing_preference_internet_enabled

  connection_configuration {
    name                      = var.p2s_vpn.connection_configuration_name
    internet_security_enabled = var.p2s_vpn.internet_security_enabled

    vpn_client_address_pool {
      address_prefixes = var.p2s_vpn.client_address_pool_prefixes
    }

    dynamic "route" {
      for_each = var.p2s_vpn.route == null ? [] : [var.p2s_vpn.route]

      content {
        associated_route_table_id = route.value["associated_route_table_id"]
        inbound_route_map_id      = route.value["inbound_route_map_id"]
        outbound_route_map_id     = route.value["outbound_route_map_id"]

        dynamic "propagated_route_table" {
          for_each = route.value["propagated_route_table"] == null ? [] : [route.value["propagated_route_table"]]
          content {
            ids    = propagated_route_table.value["ids"]
            labels = propagated_route_table.value["labels"]
          }
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "p2svpn_diagnostics" {
  count                      = var.p2s_vpn == null ? 0 : 1
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_point_to_site_vpn_gateway.p2sgw[0].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "GatewayDiagnosticLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "TunnelDiagnosticLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "RouteDiagnosticLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "IKEDiagnosticLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "P2SDiagnosticLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}

resource "azurerm_firewall" "firewall" {
  #checkov:skip=CKV_AZURE_216:Threat intel mode is inherited from firewall policy
  name                = var.firewall.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall.sku
  firewall_policy_id  = data.azurerm_firewall_policy.firewall_policy.id
  zones               = var.firewall.zone_redundant == true ? ["1", "2", "3"] : null

  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.vhub.id
    public_ip_count = var.firewall.public_ip_count
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_firewall.firewall.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AzureFirewallDnsProxy"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWApplicationRule"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWApplicationRuleAggregation"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWDnsQuery"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWFatFlow"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWFatFlow"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWFlowTrace"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWFqdnResolveFailure"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWIdpsSignature"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWNatRule"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWNatRuleAggregation"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWNetworkRule"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWNetworkRuleAggregation"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AZFWThreatIntel"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}

resource "azurerm_public_ip_prefix" "prefix" {
  for_each            = { for k in var.public_ip_prefixes : k.name => k if k != null }
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  ip_version          = each.value.ip_version
  prefix_length       = each.value.prefix_length
  zones               = [1, 2, 3]
  tags                = var.tags
}
