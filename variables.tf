variable "virtual_hub_name" {
  type        = string
  description = "Name of the virtual hub"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name to deploy to"
}

variable "location" {
  type        = string
  description = "Location of the virtual hub"
}

variable "virtual_wan_name" {
  type        = string
  description = "Name of virtual wan to deploy virtual hub to"
}

variable "virtual_wan_resource_group_name" {
  type        = string
  description = "Resource Group of the virtual wan"
}

variable "address_prefix" {
  type        = string
  description = "IP range of the virtual hub"
}

variable "hub_routing_preference" {
  type        = string
  default     = "ExpressRoute"
  description = "The hub routing preference. Possible values are ExpressRoute, ASPath and VpnGateway"
}

variable "sku" {
  type        = string
  default     = "Standard"
  description = "The SKU of the Virtual Hub. Possible values are Basic and Standard."
}

variable "routes" {
  type = list(object(
    {
      name                = string
      address_prefixes    = list(string)
      next_hop_ip_address = string
    }
  ))
  default     = []
  description = "virtual hub routes"
}

variable "p2s_vpn" {
  type = object(
    {
      vpn_server_configuration_name = string
      vpn_authentication_types      = optional(list(string), ["AAD"])
      vpn_protocols                 = optional(list(string), ["OpenVPN"])
      ipsec_policy = optional(object({
        dh_group               = string
        ike_encryption         = string
        ike_integrity          = string
        ipsec_encryption       = string
        ipsec_integrity        = string
        pfs_group              = string
        sa_lifetime_seconds    = number
        sa_data_size_kilobytes = number
      }))
      azure_active_directory_authentication = optional(object({
        issuer = string
      }))
      client_root_certificates = optional(list(object({
        name             = string
        public_cert_data = string
      })))
      client_revoked_certificates = optional(list(object({
        name       = string
        thumbprint = string
      })))
      vpn_gateway_name                    = string
      scale_unit                          = number
      dns_servers                         = optional(list(string))
      routing_preference_internet_enabled = optional(bool, false)
      connection_configuration_name       = string
      internet_security_enabled           = optional(bool, false)
      client_address_pool_prefixes        = optional(list(string))
      route = optional(object({
        associated_route_table_id = string
        inbound_route_map_id      = optional(string)
        outbound_route_map_id     = optional(string)
        propagated_route_table = optional(object({
          ids    = list(string)
          labels = optional(list(string))
        }))
      }))
    }
  )
  default     = null
  description = "Point-to-Site VPN"
}

variable "firewall" {
  type = object(
    {
      name                       = string
      sku                        = optional(string, "Standard")
      policy_name                = string
      policy_resource_group_name = string
      threat_intel_mode          = optional(string, "Deny")
      zone_redundant             = optional(bool, true)
      public_ip_count            = number
    }
  )
  description = "Azure firewall"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of Log Analytics Workspace to send diagnostics"
}

variable "log_analytics_workspace_resource_group_name" {
  type        = string
  description = "Resource Group of Log Analytics Workspace to send diagnostics"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
