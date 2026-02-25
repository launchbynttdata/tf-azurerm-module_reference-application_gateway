// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 1.0"

  for_each = var.resource_names_map

  logical_product_family  = var.product_family
  logical_product_service = var.product_service
  region                  = join("", split("-", var.region))
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  instance_resource       = var.resource_number
  maximum_length          = each.value.max_length
  use_azure_region_abbr   = true

}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.1"

  location = var.region
  name     = module.resource_names["resource_group"].minimal_random_suffix

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "virtual_network" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm"
  version = "~> 3.0"

  resource_group_name = module.resource_group.name
  vnet_name           = module.resource_names["virtual_network"].minimal_random_suffix
  vnet_location       = var.region

  address_space = ["10.60.0.0/16"]

  subnets = {
    "app-gateway-subnet" = {
      prefix = "10.60.0.0/24"
    }
  }

  tags = merge(var.tags, { resource_name = module.resource_names["virtual_network"].standard })

  depends_on = [
    module.resource_group,
  ]
}

module "application_gateway" {
  source = "../.."

  product_family         = var.product_family
  product_service        = var.product_service
  environment            = var.environment
  environment_number     = var.environment_number
  resource_number        = var.resource_number
  region                 = var.region
  resource_names_map     = var.resource_names_map
  resource_names_version = var.resource_names_version

  frontend_ip_configuration_name         = var.frontend_ip_configuration_name
  frontend_private_ip_configuration_name = var.frontend_private_ip_configuration_name
  gateway_ip_configuration_name          = var.gateway_ip_configuration_name

  sku_capacity = var.sku_capacity
  sku          = var.sku
  zones        = var.zones

  frontend_port_settings              = var.frontend_port_settings
  ssl_policy                          = var.ssl_policy
  ssl_profile                         = var.ssl_profile
  firewall_policy_id                  = var.firewall_policy_id
  custom_error_configuration          = var.custom_error_configuration
  appgw_redirect_configuration        = var.appgw_redirect_configuration
  appgw_rewrite_rule_set              = var.appgw_rewrite_rule_set
  force_firewall_policy_association   = var.force_firewall_policy_association
  waf_configuration                   = var.waf_configuration
  disable_waf_rules_for_dev_portal    = var.disable_waf_rules_for_dev_portal
  trusted_client_certificates_configs = var.trusted_client_certificates_configs
  trusted_root_certificate_configs    = var.trusted_root_certificate_configs
  ssl_certificates_configs            = var.ssl_certificates_configs
  authentication_certificates_configs = var.authentication_certificates_configs

  appgw_backend_pools         = var.appgw_backend_pools
  appgw_http_listeners        = var.appgw_http_listeners
  appgw_routings              = var.appgw_routings
  appgw_probes                = var.appgw_probes
  appgw_backend_http_settings = var.appgw_backend_http_settings
  appgw_url_path_map          = var.appgw_url_path_map

  subnet_id                    = module.virtual_network.subnet_name_id_map["app-gateway-subnet"]
  user_assigned_identity_id    = var.user_assigned_identity_id
  create_user_managed_identity = var.create_user_managed_identity
  appgw_private                = var.appgw_private
  enable_http2                 = var.enable_http2
  autoscaling_parameters       = var.autoscaling_parameters
  role_assignments             = var.role_assignments
  custom_private_dns_record    = var.custom_private_dns_record

  create_waf_policy          = var.create_waf_policy
  waf_policy_custom_rules    = var.waf_policy_custom_rules
  waf_policy_settings        = var.waf_policy_settings
  waf_policy_managed_rules   = var.waf_policy_managed_rules
  log_analytics_workspace    = var.log_analytics_workspace
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_settings        = var.diagnostic_settings
  tags                       = var.tags
}
