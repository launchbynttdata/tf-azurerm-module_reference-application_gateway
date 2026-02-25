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
# COMMON
variable "product_family" {
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  type        = string
  default     = "dso"
}

variable "product_service" {
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  type        = string
  default     = "app"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "region" {
  description = "AWS Region in which the infra needs to be provisioned"
  type        = string
  default     = "eastus"
}

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object(
    {
      name       = string
      max_length = optional(number, 60)
    }
  ))
  default = {
    app_gateway = {
      name       = "appgw"
      max_length = 60
    }
    public_ip = {
      name       = "pip"
      max_length = 60
    }
    resource_group = {
      name       = "rg"
      max_length = 60
    }
    nsg = {
      name       = "nsg"
      max_length = 60
    }
    msi = {
      name       = "msi"
      max_length = 60
    }
    waf_policy = {
      name       = "waf"
      max_length = 60
    }
  }
}

variable "resource_names_version" {
  description = "Major version of the resource names module to use"
  type        = string
  default     = "1"
}

# PUBLIC IP

variable "frontend_ip_configuration_name" {
  description = "Name of the frontend IP configuration."
  type        = string
  default     = "standard-public-ip"
}


variable "frontend_private_ip_configuration_name" {
  description = "Name of the frontend private IP configuration. Mandatory when appgw_private is set to true."
  type        = string
  default     = "standard-private-ip"
}
# Application gateway inputs

variable "gateway_ip_configuration_name" {
  description = "Name of the gateway IP configuration."
  type        = string
  default     = "app-gateway-ip"
}

variable "sku_capacity" {
  description = "The Capacity of the SKU to use for this Application Gateway - which must be between 1 and 10, optional if autoscale_configuration is set"
  type        = number
  default     = 2
}

variable "sku" {
  description = "The Name of the SKU to use for this Application Gateway. Possible values are Standard_v2 and WAF_v2."
  type        = string
  default     = "Standard_v2"
}

variable "zones" {
  description = "A collection of availability zones to spread the Application Gateway over. This option is only supported for v2 SKUs"
  type        = list(number)
  default     = [1, 2, 3]
}

variable "frontend_port_settings" {
  description = "Frontend port settings. Each port setting contains the name and the port for the frontend port."
  type = list(object({
    name = string
    port = number
  }))
}

variable "ssl_policy" {
  description = "Application Gateway SSL configuration. The list of available policies can be found here: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#disabled_protocols"
  type = object({
    disabled_protocols   = optional(list(string), [])
    policy_type          = optional(string, "Predefined")
    policy_name          = optional(string, "AppGwSslPolicy20170401S")
    cipher_suites        = optional(list(string), [])
    min_protocol_version = optional(string, "TLSv1_2")
  })
  default = null
}

variable "ssl_profile" {
  description = "Application Gateway SSL profile. Default profile is used when this variable is set to null. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#name"
  type = list(object({
    name                             = string
    trusted_client_certificate_names = optional(list(string), [])
    verify_client_cert_issuer_dn     = optional(bool, false)
    ssl_policy = optional(object({
      disabled_protocols   = optional(list(string), [])
      policy_type          = optional(string, "Predefined")
      policy_name          = optional(string, "AppGwSslPolicy20170401S")
      cipher_suites        = optional(list(string), [])
      min_protocol_version = optional(string, "TLSv1_2")
    }))
  }))
  default  = []
  nullable = false
}

variable "firewall_policy_id" {
  description = "ID of a Web Application Firewall Policy"
  type        = string
  default     = null
}

variable "trusted_root_certificate_configs" {
  description = "List of trusted root certificates. `file_path` is checked first, using `data` (base64 cert content) if null. This parameter is required if you are not using a trusted certificate authority (eg. selfsigned certificate)."
  type = list(object({
    name                = string
    data                = optional(string)
    file_path           = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "appgw_backend_pools" {
  description = "List of objects with backend pool configurations."
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
}

variable "appgw_http_listeners" {
  description = <<EOT
    List of objects with HTTP listeners configurations and custom error configurations.
    The field `frontend_ip_configuration_name` may not be set. By default, the listener attaches to the public IP of the App Gateway.
    If appgw_private is set to true, the listener will attach to the private IP of the App Gateway.
    If user needs to override this behavior, they can set the `frontend_ip_configuration_name` to the name of the frontend IP configuration.
  EOT
  type = list(object({
    name = string

    frontend_ip_configuration_name = optional(string)
    frontend_port_name             = optional(string)
    host_name                      = optional(string)
    host_names                     = optional(list(string))
    protocol                       = optional(string, "Https")
    require_sni                    = optional(bool, false)
    ssl_certificate_name           = optional(string)
    ssl_profile_name               = optional(string)
    firewall_policy_id             = optional(string)

    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })), [])
  }))
}

variable "custom_error_configuration" {
  description = "List of objects with global level custom error configurations."
  type = list(object({
    status_code           = string
    custom_error_page_url = string
  }))
  default = []
}

variable "ssl_certificates_configs" {
  description = <<EOD
List of objects with SSL certificates configurations.
The path to a base-64 encoded certificate is expected in the 'data' attribute:
```
data = filebase64("./file_path")
```
EOD
  type = list(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "authentication_certificates_configs" {
  description = <<EOD
List of objects with authentication certificates configurations.
The path to a base-64 encoded certificate is expected in the 'data' attribute:
```
data = filebase64("./file_path")
```
EOD
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "trusted_client_certificates_configs" {
  description = <<EOD
List of objects with trusted client certificates configurations.
The path to a base-64 encoded certificate is expected in the 'data' attribute:
```
data = filebase64("./file_path")
```
EOD
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "appgw_routings" {
  description = <<EOT
    List of objects with request routing rules configurations. With AzureRM v3+ provider, `priority` attribute becomes mandatory.
    Each Routing rule is associated with a particular listener and determines how traffic are routed to the backend pool.
    Multiple routing rules cannot be associated with the same listener.

    rule_type="PathBasedRouting" can be used to route traffic to multiple backends based on the URL path, else rule_type="Basic" is used.

    `url_path_map_name` is required when rule_type="PathBasedRouting" and is used to define the URL path map configuration.
  EOT

  type = list(object({
    name                        = string
    rule_type                   = optional(string, "Basic")
    http_listener_name          = optional(string)
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    url_path_map_name           = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    priority                    = optional(number)
  }))
}

variable "appgw_probes" {
  description = <<EOT
    List of objects with probes configurations.
    Probes are used to determine the health of the backend servers.
    User needs to define custom probes only when the default probe is not sufficient, for example when the backend server
    uses a different port or path or protocol.

    Additional checks can be added to the default probe by setting the `match` attribute to compare the return status code
    or the response body

  EOT
  type = list(object({
    name     = string
    host     = optional(string)
    port     = optional(number, null)
    interval = optional(number, 30)
    path     = optional(string, "/")
    protocol = optional(string, "Https")
    timeout  = optional(number, 30)

    unhealthy_threshold                       = optional(number, 3)
    pick_host_name_from_backend_http_settings = optional(bool, false)
    minimum_servers                           = optional(number, 0)

    match = optional(object({
      body        = optional(string, "")
      status_code = optional(list(string), ["200-399"])
    }), {})
  }))
  default = []
}

variable "appgw_backend_http_settings" {
  description = <<EOT
    List of objects including backend http settings configurations.
    Each backend pool must be associated with a backend http settings configuration.
  EOT
  type = list(object({
    name     = string
    port     = optional(number, 443)
    protocol = optional(string, "Https")

    path       = optional(string)
    probe_name = optional(string)

    cookie_based_affinity               = optional(string, "Disabled")
    affinity_cookie_name                = optional(string, "ApplicationGatewayAffinity")
    request_timeout                     = optional(number, 20)
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool, true)
    trusted_root_certificate_names      = optional(list(string), [])
    authentication_certificate          = optional(string)

    connection_draining_timeout_sec = optional(number)
  }))
}

variable "appgw_url_path_map" {
  description = <<EOT
    List of objects with URL path map configurations.
    This is mandatory when the routing rule_type is set to "PathBasedRouting". Path mapping must be specified to
    route traffic to multiple backends based on the URL path.

  EOT
  type = list(object({
    name = string

    default_backend_address_pool_name   = optional(string)
    default_redirect_configuration_name = optional(string)
    default_backend_http_settings_name  = optional(string)
    default_rewrite_rule_set_name       = optional(string)

    path_rules = list(object({
      name = string

      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      rewrite_rule_set_name       = optional(string)
      redirect_configuration_name = optional(string)

      paths = optional(list(string), [])
    }))
  }))
  default = []
}

variable "appgw_redirect_configuration" {
  description = "List of objects with redirect configurations."
  type = list(object({
    name = string

    redirect_type        = optional(string, "Permanent")
    target_listener_name = optional(string)
    target_url           = optional(string)

    include_path         = optional(bool, true)
    include_query_string = optional(bool, true)
  }))
  default = []
}

### REWRITE RULE SET

variable "appgw_rewrite_rule_set" {
  description = "List of rewrite rule set objects with rewrite rules."
  type = list(object({
    name = string
    rewrite_rules = list(object({
      name          = string
      rule_sequence = string

      conditions = optional(list(object({
        variable    = string
        pattern     = string
        ignore_case = optional(bool, false)
        negate      = optional(bool, false)
      })), [])

      response_header_configurations = optional(list(object({
        header_name  = string
        header_value = string
      })), [])

      request_header_configurations = optional(list(object({
        header_name  = string
        header_value = string
      })), [])

      url_reroute = optional(object({
        path         = optional(string)
        query_string = optional(string)
        components   = optional(string)
        reroute      = optional(bool)
      }))
    }))
  }))
  default = []
}

### WAF (legacy)

variable "force_firewall_policy_association" {
  description = "Enable if the Firewall Policy is associated with the Application Gateway."
  type        = bool
  default     = false
}

variable "waf_configuration" {
  description = <<EOD
    WAF configuration object (only available with WAF_v2 SKU) with following attributes:
    ```
    - enabled:                  Boolean to enable WAF.
    - file_upload_limit_mb:     The File Upload Limit in MB. Accepted values are in the range 1MB to 500MB.
    - firewall_mode:            The Web Application Firewall Mode. Possible values are Detection and Prevention.
    - max_request_body_size_kb: The Maximum Request Body Size in KB. Accepted values are in the range 1KB to 128KB.
    - request_body_check:       Is Request Body Inspection enabled ?
    - rule_set_type:            The Type of the Rule Set used for this Web Application Firewall.
    - rule_set_version:         The Version of the Rule Set used for this Web Application Firewall. Possible values are 2.2.9, 3.0, and 3.1.
    - disabled_rule_group:      The rule group where specific rules should be disabled. Accepted values can be found here: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#rule_group_name
    - exclusion:                WAF exclusion rules to exclude header, cookie or GET argument. More informations on: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#match_variable
    ```
  EOD
  type = object({
    enabled                  = optional(bool, true)
    file_upload_limit_mb     = optional(number, 100)
    firewall_mode            = optional(string, "Prevention")
    max_request_body_size_kb = optional(number, 128)
    request_body_check       = optional(bool, true)
    rule_set_type            = optional(string, "OWASP")
    rule_set_version         = optional(string, 3.1)
    disabled_rule_group = optional(list(object({
      rule_group_name = string
      rules           = optional(list(string))
    })), [])
    exclusion = optional(list(object({
      match_variable          = string
      selector                = optional(string)
      selector_match_operator = optional(string)
    })), [])
  })
  default = {}
}

variable "disable_waf_rules_for_dev_portal" {
  description = "Whether to disable some WAF rules if the APIM developer portal is hosted behind this Application Gateway. See locals.tf for the documentation link."
  type        = bool
  default     = false
}

### WAF POLICY

variable "create_waf_policy" {
  description = "Create a Web Application Firewall Policy and associate it with the Application Gateway?"
  type        = bool
  default     = false
}

variable "waf_policy_custom_rules" {
  description = "Custom rules of the firewall policy."
  type = list(object({
    name      = string
    priority  = number
    rule_type = string
    action    = string

    rate_limit_duration  = optional(string)
    rate_limit_threshold = optional(number)
    group_rate_limit_by  = optional(string)

    match_conditions = list(object({
      match_variables = list(object({
        variable_name = string
        selector      = optional(string)
      }))
      operator           = string
      negation_condition = optional(bool)
      match_values       = optional(list(string))
      transforms         = optional(list(string))
    }))
  }))
  default = null
}

variable "waf_policy_settings" {
  description = "Policy settings of the firewall policy."
  type = object({
    enabled                                   = optional(bool)
    mode                                      = optional(string)
    request_body_check                        = optional(bool)
    file_upload_limit_in_mb                   = optional(number)
    max_request_body_size_in_kb               = optional(number)
    request_body_inspect_limit_in_kb          = optional(number)
    js_challenge_cookie_expiration_in_minutes = optional(number)
  })
  default = {
    enabled                                   = null
    mode                                      = null
    request_body_check                        = null
    file_upload_limit_in_mb                   = null
    max_request_body_size_in_kb               = null
    request_body_inspect_limit_in_kb          = null
    js_challenge_cookie_expiration_in_minutes = null
  }
}

variable "waf_policy_managed_rules" {
  description = "Managed rules of the firewall policy."
  type = object({
    exclusions = optional(list(object({
      match_variable          = string
      selector                = string
      selector_match_operator = string
      excluded_rule_sets = list(object({
        type    = string
        version = string
        rule_groups = list(object({
          rule_group_name = string
          excluded_rules  = list(string)
        }))
      }))
    }))),
    managed_rule_sets = list(object({
      type    = string
      version = string
      rule_group_overrides = optional(list(object({
        rule_group_name = string
        rules = optional(list(object({
          id      = number
          enabled = optional(bool)
          action  = optional(string)
        })))
      })))
    }))
  })
  default = {
    managed_rule_sets = [
      {
        type    = "OWASP"
        version = "3.2"
      }
    ]
  }
}

### NETWORKING

variable "subnet_id" {
  description = "Subnet ID for attaching the Application Gateway. This is mandatory for v2 SKUs"
  type        = string
  nullable    = false
}

variable "private_ip_address" {
  type        = string
  description = "The private IP address of the Application Gateway. Must be within the range of the subnet. Required only when appgw_private is set to true."
  default     = ""
}

### IDENTITY

variable "user_assigned_identity_id" {
  description = "User assigned identity id assigned to this resource. User can choose to pass in an existing identity or create a new one with create_user_managed_identity."
  type        = string
  default     = null
}

variable "create_user_managed_identity" {
  description = "Creates an user assigned managed Identity and assigns it to the Application Gateway. If this is true, user_assigned_identity_id will be ignored."
  type        = bool
  default     = true
}

### APPGW PRIVATE

variable "appgw_private" {
  description = "Boolean variable to create a private Application Gateway. When `true`, the default http listener will listen on private IP instead of the public IP."
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Whether to enable http2 or not"
  type        = bool
  default     = true
}

### Autoscaling

variable "autoscaling_parameters" {
  description = "Map containing autoscaling parameters. Must contain at least min_capacity"
  type = object({
    min_capacity = number
    max_capacity = optional(number, 5)
  })
  default = null
}

variable "role_assignments" {
  description = <<EOT
    A map of role assignments to be associated with the user assigned managed identity of the Application Gateway
    Should be of the format
    {
      private-dns = ["Private DNS Zone Contributor", "<private-dns-zone-id>"]
      key-vault = ["Key Vault Administrator", "<key-vault-id>"]
    }
  EOT
  type        = map(list(string))
  default     = {}
}

# Custom private DNS name

variable "custom_private_dns_record" {
  description = <<EOT
    Custom private DNS record for the Application Gateway. An A-record would be created for the private IP address.
    Valid `private_dns_zone_name` and `private_dns_zone_rg` must be provided. `name` must be only the sub-domain without the zone name.
  EOT
  type = object({
    name                  = string
    ttl                   = optional(number, 300)
    private_dns_zone_name = string
    private_dns_zone_rg   = string
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "diagnostic_settings" {
  type = map(object({
    enabled_log = optional(list(object({
      category_group = optional(string, "allLogs")
      category       = optional(string, null)
    })))
    metrics = optional(list(object({
      category = string
      enabled  = optional(bool)
    })))
  }))
  default = {}
}

variable "log_analytics_workspace" {
  type = object({
    sku               = string
    retention_in_days = number
    daily_quota_gb    = number
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    local_authentication_disabled = optional(bool)
  })
  default = null
}
variable "log_analytics_workspace_id" {
  type        = string
  description = "(Optional) The ID of the Log Analytics Workspace."
  default     = null
}
