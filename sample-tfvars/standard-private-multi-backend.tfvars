product_family  = "dso"
product_service = "appgw"

sku          = "Standard_v2"
sku_capacity = 1

zones = [1, 2, 3]

appgw_private      = true
subnet_id          = "<subnet_id>"
private_ip_address = "<ip_address_in_subnet>"

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
    fqdns = ["<apim_fqdn>"]
  },
  {
    name  = "python_ingress_nginx_backend_pool"
    fqdns = ["<ingress_fqdn>"]
  }
]

appgw_routings = [
  {
    name                       = "https_routing_rule"
    backend_address_pool_name  = "apim_backend_pool"
    backend_http_settings_name = "apim_backend_http_settings"
    http_listener_name         = "https_listener"
    url_path_map_name          = "https_path_mapping"
    priority                   = 100
    rule_type                  = "PathBasedRouting"
  }
]

appgw_http_listeners = [
  {
    name               = "http_listener"
    frontend_port_name = "port_80"
    protocol           = "Http"
  },
  {
    name                 = "https_listener"
    frontend_port_name   = "port_443"
    protocol             = "Https"
    hostname             = "<app_gateway_custom_host_name>"
    ssl_certificate_name = "appgw-cert"
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
    path                                = "/"
  },
  {
    name                                = "ingress_nginx_python_backend_http_settings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
    trusted_root_certificate_names      = ["cert-manager-root-ca"]
  }
]

appgw_url_path_map = [
  {
    name                               = "https_path_mapping"
    default_backend_address_pool_name  = "python_ingress_nginx_backend_pool"
    default_backend_http_settings_name = "ingress_nginx_python_backend_http_settings"
    path_rules = [
      {
        name                       = "apis"
        paths                      = ["/apis/*"]
        backend_address_pool_name  = "apim_backend_pool"
        backend_http_settings_name = "apim_backend_http_settings"
      }
    ]
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

create_user_managed_identity = true
role_assignments = {
  key-vault = ["Key Vault Secrets User", "<key_vault_id>"]
}

# key_vault_secret_id must be a secret. certificate is not working
# The cert must be in pfx format (no password), then base64 encoded and added as a secret to the Key vault
ssl_certificates_configs = [
  {
    name                = "appgw-cert"
    key_vault_secret_id = "<secret_url>"
  }
]

custom_private_dns_record = {
  name                  = "apgw"
  private_dns_zone_name = "<private_dns_zone_name>"
  private_dns_zone_rg   = "<private_dns_zone_rg>"
}

# key_vault_secret_id must be a secret. The secret must be the base64 encoded certificate. Currently tested with pem format certs
trusted_root_certificate_configs = [
  {
    name                = "cert-manager-root-ca"
    key_vault_secret_id = "<key_vault_secret_id>"
  }
]
