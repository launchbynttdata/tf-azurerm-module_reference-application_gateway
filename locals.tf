locals {
  use_v2_resource_names = (var.resource_names_version == "2")
  resource_group_name   = local.use_v2_resource_names ? module.resource_names_v2["resource_group"].standard : module.resource_names["resource_group"].standard
  public_ip_name        = local.use_v2_resource_names ? module.resource_names_v2["public_ip"].standard : module.resource_names["public_ip"].standard
  identity_name         = local.use_v2_resource_names ? module.resource_names_v2["msi"].standard : module.resource_names["msi"].standard
  gateway_name          = local.use_v2_resource_names ? module.resource_names_v2["app_gateway"].standard : module.resource_names["app_gateway"].standard
}
