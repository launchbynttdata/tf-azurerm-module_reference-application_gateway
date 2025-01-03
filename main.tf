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

module "resource_names_v2" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = local.use_v2_resource_names ? var.resource_names_map : {}

  region                  = join("", split("-", var.region))
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  instance_resource       = var.resource_number
  maximum_length          = each.value.max_length
  logical_product_family  = var.product_family
  logical_product_service = var.product_service
  use_azure_region_abbr   = true
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  location = var.region
  name     = local.resource_group_name

  tags = merge(var.tags, { resource_name = local.resource_group_name })
}

module "public_ip" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/public_ip/azurerm"
  version = "~> 1.0"

  name                = local.public_ip_name
  resource_group_name = module.resource_group.name
  location            = var.region
  allocation_method   = "Static"
  domain_name_label   = local.public_ip_name
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones               = var.zones

  tags = merge(var.tags, {
    resource_name = local.public_ip_name
  })

  depends_on = [module.resource_group]
}

module "managed_identity" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/user_managed_identity/azurerm"
  version = "~> 1.0"

  count = var.create_user_managed_identity ? 1 : 0

  resource_group_name         = module.resource_group.name
  location                    = var.region
  user_assigned_identity_name = local.identity_name

  depends_on = [module.resource_group]
}

module "identity_roles" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm"
  version = "~> 1.0"

  for_each = var.create_user_managed_identity ? var.role_assignments : {}

  principal_id         = module.managed_identity[0].principal_id
  role_definition_name = each.value[0]
  scope                = each.value[1]

  depends_on = [module.managed_identity, module.resource_group]
}

module "private_dns_record" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_records/azurerm"
  version = "~> 1.0"

  count = var.appgw_private && var.custom_private_dns_record != null ? 1 : 0

  a_records = {
    app_gateway = {
      name                = var.custom_private_dns_record["name"]
      zone_name           = var.custom_private_dns_record["private_dns_zone_name"]
      resource_group_name = var.custom_private_dns_record["private_dns_zone_rg"]
      ttl                 = var.custom_private_dns_record["ttl"]
      records             = [var.private_ip_address]
    }
  }
}

module "application_gateway" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/application_gateway/azurerm"
  version = "~> 1.0"

  name                                   = local.gateway_name
  location                               = var.region
  resource_group_name                    = module.resource_group.name
  frontend_ip_configuration_name         = var.frontend_ip_configuration_name
  public_ip_address_id                   = module.public_ip.id
  frontend_private_ip_configuration_name = var.frontend_private_ip_configuration_name
  gateway_ip_configuration_name          = var.gateway_ip_configuration_name
  sku                                    = var.sku
  sku_capacity                           = var.sku_capacity
  ssl_policy                             = var.ssl_policy
  ssl_profile                            = var.ssl_profile
  firewall_policy_id                     = var.firewall_policy_id
  custom_error_configuration             = var.custom_error_configuration
  appgw_redirect_configuration           = var.appgw_redirect_configuration
  appgw_rewrite_rule_set                 = var.appgw_rewrite_rule_set
  force_firewall_policy_association      = var.force_firewall_policy_association
  waf_configuration                      = var.waf_configuration
  disable_waf_rules_for_dev_portal       = var.disable_waf_rules_for_dev_portal
  zones                                  = var.zones
  frontend_port_settings                 = var.frontend_port_settings
  trusted_client_certificates_configs    = var.trusted_client_certificates_configs
  trusted_root_certificate_configs       = var.trusted_root_certificate_configs
  appgw_backend_pools                    = var.appgw_backend_pools
  appgw_http_listeners                   = var.appgw_http_listeners
  appgw_routings                         = var.appgw_routings
  appgw_probes                           = var.appgw_probes
  appgw_backend_http_settings            = var.appgw_backend_http_settings
  appgw_url_path_map                     = var.appgw_url_path_map
  subnet_id                              = var.subnet_id
  user_assigned_identity_id              = var.create_user_managed_identity ? module.managed_identity[0].id : var.user_assigned_identity_id
  appgw_private                          = var.appgw_private
  appgw_private_ip                       = var.private_ip_address
  enable_http2                           = var.enable_http2
  autoscaling_parameters                 = var.autoscaling_parameters
  ssl_certificates_configs               = var.ssl_certificates_configs
  authentication_certificates_configs    = var.authentication_certificates_configs

  tags = merge(var.tags, {
    resource_name = local.gateway_name
  })

  depends_on = [module.resource_group, module.public_ip, module.managed_identity, module.identity_roles]
}
