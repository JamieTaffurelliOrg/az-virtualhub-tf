# az-virtualhub-tf

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.65.0 |
| <a name="provider_azurerm.logs"></a> [azurerm.logs](#provider\_azurerm.logs) | 3.65.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_monitor_diagnostic_setting.firewall_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.p2svpn_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_point_to_site_vpn_gateway.p2sgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/point_to_site_vpn_gateway) | resource |
| [azurerm_public_ip_prefix.prefix](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) | resource |
| [azurerm_virtual_hub.vhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub) | resource |
| [azurerm_vpn_server_configuration.vpn_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_server_configuration) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_firewall_policy.firewall_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/firewall_policy) | data source |
| [azurerm_log_analytics_workspace.logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_virtual_wan.vwan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_wan) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_prefix"></a> [address\_prefix](#input\_address\_prefix) | IP range of the virtual hub | `string` | n/a | yes |
| <a name="input_firewall"></a> [firewall](#input\_firewall) | Azure firewall | <pre>object(<br>    {<br>      name                       = string<br>      sku                        = optional(string, "Standard")<br>      policy_name                = string<br>      policy_resource_group_name = string<br>      threat_intel_mode          = optional(string, "Deny")<br>      zone_redundant             = optional(bool, true)<br>      public_ip_count            = number<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_hub_routing_preference"></a> [hub\_routing\_preference](#input\_hub\_routing\_preference) | The hub routing preference. Possible values are ExpressRoute, ASPath and VpnGateway | `string` | `"ExpressRoute"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the virtual hub | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of Log Analytics Workspace to send diagnostics | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_resource_group_name"></a> [log\_analytics\_workspace\_resource\_group\_name](#input\_log\_analytics\_workspace\_resource\_group\_name) | Resource Group of Log Analytics Workspace to send diagnostics | `string` | n/a | yes |
| <a name="input_p2s_vpn"></a> [p2s\_vpn](#input\_p2s\_vpn) | Point-to-Site VPN | <pre>object(<br>    {<br>      vpn_server_configuration_name = string<br>      vpn_authentication_types      = optional(list(string), ["AAD"])<br>      vpn_protocols                 = optional(list(string), ["OpenVPN"])<br>      ipsec_policy = optional(object({<br>        dh_group               = string<br>        ike_encryption         = string<br>        ike_integrity          = string<br>        ipsec_encryption       = string<br>        ipsec_integrity        = string<br>        pfs_group              = string<br>        sa_lifetime_seconds    = number<br>        sa_data_size_kilobytes = number<br>      }))<br>      azure_active_directory_authentication = optional(object({<br>        issuer = string<br>      }))<br>      client_root_certificates = optional(list(object({<br>        name             = string<br>        public_cert_data = string<br>      })))<br>      client_revoked_certificates = optional(list(object({<br>        name       = string<br>        thumbprint = string<br>      })))<br>      vpn_gateway_name                    = string<br>      scale_unit                          = number<br>      dns_servers                         = optional(list(string))<br>      routing_preference_internet_enabled = optional(bool, false)<br>      connection_configuration_name       = string<br>      internet_security_enabled           = optional(bool, false)<br>      client_address_pool_prefixes        = optional(list(string))<br>      route = optional(object({<br>        associated_route_table_id = string<br>        inbound_route_map_id      = optional(string)<br>        outbound_route_map_id     = optional(string)<br>        propagated_route_table = optional(object({<br>          ids    = list(string)<br>          labels = optional(list(string))<br>        }))<br>      }))<br>    }<br>  )</pre> | `null` | no |
| <a name="input_public_ip_prefixes"></a> [public\_ip\_prefixes](#input\_public\_ip\_prefixes) | Public IP prefixes to deploy | <pre>list(object(<br>    {<br>      name          = string<br>      ip_version    = optional(string, "IPv4")<br>      prefix_length = number<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group name to deploy to | `string` | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | virtual hub routes | <pre>list(object(<br>    {<br>      name                = string<br>      address_prefixes    = list(string)<br>      next_hop_ip_address = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Virtual Hub. Possible values are Basic and Standard. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | n/a | yes |
| <a name="input_virtual_hub_name"></a> [virtual\_hub\_name](#input\_virtual\_hub\_name) | Name of the virtual hub | `string` | n/a | yes |
| <a name="input_virtual_wan_name"></a> [virtual\_wan\_name](#input\_virtual\_wan\_name) | Name of virtual wan to deploy virtual hub to | `string` | n/a | yes |
| <a name="input_virtual_wan_resource_group_name"></a> [virtual\_wan\_resource\_group\_name](#input\_virtual\_wan\_resource\_group\_name) | Resource Group of the virtual wan | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
