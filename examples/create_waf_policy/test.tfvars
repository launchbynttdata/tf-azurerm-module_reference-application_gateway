sku = "WAF_v2"

create_waf_policy                 = true
force_firewall_policy_association = true

waf_policy_custom_rules = [
  {
    name      = "allowips"
    priority  = 10
    rule_type = "MatchRule"
    action    = "Allow"

    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "RemoteAddr"
          }
        ]
        operator     = "IPMatch"
        match_values = ["192.0.2.10", "198.51.100.0/24"]
        transforms   = []
      },
      {
        match_variables = [
          {
            variable_name = "RequestHeaders"
            selector      = "User-Agent"
          }
        ]
        operator           = "Contains"
        negation_condition = true
        match_values       = ["curl"]
        transforms         = ["Lowercase"]
      }
    ]
  },
  {
    name      = "ratelimit"
    priority  = 20
    rule_type = "RateLimitRule"
    action    = "Block"

    rate_limit_duration  = "OneMin"
    rate_limit_threshold = 100
    group_rate_limit_by  = "ClientAddr"

    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "RequestUri"
          }
        ]
        operator     = "Contains"
        match_values = ["/api"]
      }
    ]
  }
]

waf_policy_settings = {
  enabled                                   = true
  mode                                      = "Prevention"
  request_body_check                        = true
  file_upload_limit_in_mb                   = 100
  max_request_body_size_in_kb               = 128
  request_body_inspect_limit_in_kb          = 128
  js_challenge_cookie_expiration_in_minutes = 30
}

waf_policy_managed_rules = {
  exclusions = [
    {
      match_variable          = "RequestHeaderNames"
      selector                = "x-ignore"
      selector_match_operator = "Equals"
      excluded_rule_sets = [
        {
          type    = "OWASP"
          version = "3.2"
          rule_groups = [
            {
              rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
              excluded_rules  = ["930120", "930130"]
            }
          ]
        }
      ]
    }
  ]

  managed_rule_sets = [
    {
      type    = "OWASP"
      version = "3.2"
      rule_group_overrides = [
        {
          rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
          rules = [
            {
              id      = 942100
              enabled = false
              action  = "Log"
            },
            {
              id = 942200
              # enabled/action omitted to cover optional path
            }
          ]
        }
      ]
    }
  ]
}
ssl_policy = {
  disabled_protocols   = []
  policy_type          = "Predefined"
  policy_name          = "AppGwSslPolicy20220101S"
  cipher_suites        = []
  min_protocol_version = "TLSv1_2"
}

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
    name         = "apim_backend_pool"
    ip_addresses = ["10.60.0.20"]
  }
]

appgw_routings = [
  {
    name                       = "apim_routing"
    backend_address_pool_name  = "apim_backend_pool"
    backend_http_settings_name = "apim_backend_http_settings"
    http_listener_name         = "http_listener"
    #url_path_map_name    = "url_path_map"
    priority = 100
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
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
  }
]

frontend_ip_configuration_name         = "standard-frontend-ip"
frontend_private_ip_configuration_name = "standard-private-ip"
gateway_ip_configuration_name          = "app-gateway-ip"

tags = {
  environment = "dev"
  owner       = "example"
}
