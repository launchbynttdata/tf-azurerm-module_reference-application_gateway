product_family  = "dso"
product_service = "appgw"

sku          = "Standard_v2"
sku_capacity = 1

zones = [1, 2, 3]

appgw_private = true
# Subnet ID in form of "/subscriptions/<subscription>/resourceGroups/<rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>"
subnet_id = ""
# IP address to be assigned to App gateway. Must be in the above subnet range.
private_ip_address = "<private_ip>"

frontend_port_settings = [
  {
    name = "port_80"
    port = 80
  },
  {
    name = "port_443"
    port = 443
  }
]

appgw_backend_pools = [
  {
    name  = "apim_backend_pool"
    fqdns = ["<apim-fqdn>"]
  }
]

appgw_routings = [
  {
    name                       = "apim_routing"
    backend_address_pool_name  = "apim_backend_pool"
    backend_http_settings_name = "apim_backend_http_settings"
    http_listener_name         = "http_listener"
    priority                   = 100
  }
]

appgw_http_listeners = [
  {
    name               = "http_listener"
    frontend_port_name = "port_80"
    protocol           = "Http"
  }
]

appgw_backend_http_settings = [
  {
    name                                = "apim_backend_http_settings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
    probe_name                          = "apim_probe"
  }
]

appgw_probes = [
  {
    name                                      = "apim_probe"
    protocol                                  = "Https"
    path                                      = "/dotnet/env"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match = {
      # Backend needs authentication. No endpoint without authentication currently available
      status_code = ["401"]
    }
  }
]

frontend_ip_configuration_name         = "standard-frontend-ip"
frontend_private_ip_configuration_name = "standard-private-ip"
gateway_ip_configuration_name          = "app-gateway-ip"
