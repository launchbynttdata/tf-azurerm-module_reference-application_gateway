# tf-azurerm-module_reference-application_gateway

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This terraform module provisions an Azure Application Gateway with all its dependencies. It supports the SKUs `Standard_V2` and
`WAF_V2`. At the time of creating this module, its possible to provision either Public only or both Private and public
Application Gateway instance. The Private only is currently in Preview and is not supported by this module. The only input to this module is the
subnet in which the Application Gateway should be deployed.

This reference module is built as a wrapper around the primitive module [tf-azurerm-module_primitive-application_gateway](https://github.com/launchbynttdata/tf-azurerm-module_primitive-application_gateway)

It provisions the following resources:
- Resource Group
- Application Gateway
- WAF (optional)
- Public IP
- Custom Domain Name
- TLS Certificates for listeners
- User Assigned Managed Identity (MSI)
- Role Assignment for MSI to access services like KeyVault

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. _THIS STEP APPLIES ONLY TO MICROSOFT AZURE. IF YOU ARE USING A DIFFERENT PLATFORM PLEASE SKIP THIS STEP._ The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `azure_env.sh` file on local workstation. Devloper would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Service principle used for authentication(value of ARM_CLIENT_ID) should have below privileges on resource group within the subscription.

```
"Microsoft.Resources/subscriptions/resourceGroups/write"
"Microsoft.Resources/subscriptions/resourceGroups/read"
"Microsoft.Resources/subscriptions/resourceGroups/delete"
```

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `azure` specific. If primitive/segment under development uses any other cloud provider than azure, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "azurerm" {
  features {}
}
```

- A file named `terraform.tfvars` which contains key value pair of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | <= 1.5.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.77 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | git::https://github.com/launchbynttdata/tf-launch-module_library-resource_name.git | 1.0.1 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-resource_group.git | 1.0.0 |
| <a name="module_public_ip"></a> [public\_ip](#module\_public\_ip) | git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-public_ip | 1.0.0 |
| <a name="module_managed_identity"></a> [managed\_identity](#module\_managed\_identity) | git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-user_managed_identity.git | 1.0.0 |
| <a name="module_identity_roles"></a> [identity\_roles](#module\_identity\_roles) | git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-role_assignment.git | 1.0.0 |
| <a name="module_private_dns_record"></a> [private\_dns\_record](#module\_private\_dns\_record) | git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-private_dns_records.git | 1.0.0 |
| <a name="module_application_gateway"></a> [application\_gateway](#module\_application\_gateway) | git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-application_gateway.git | feature/init |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_product_family"></a> [product\_family](#input\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"dso"` | no |
| <a name="input_product_service"></a> [product\_service](#input\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"app"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"eastus"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object(<br>    {<br>      name       = string<br>      max_length = optional(number, 60)<br>    }<br>  ))</pre> | <pre>{<br>  "app_gateway": {<br>    "max_length": 60,<br>    "name": "appgw"<br>  },<br>  "msi": {<br>    "max_length": 60,<br>    "name": "msi"<br>  },<br>  "nsg": {<br>    "max_length": 60,<br>    "name": "nsg"<br>  },<br>  "public_ip": {<br>    "max_length": 60,<br>    "name": "pip"<br>  },<br>  "resource_group": {<br>    "max_length": 60,<br>    "name": "rg"<br>  }<br>}</pre> | no |
| <a name="input_frontend_ip_configuration_name"></a> [frontend\_ip\_configuration\_name](#input\_frontend\_ip\_configuration\_name) | Name of the frontend IP configuration. | `string` | n/a | yes |
| <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id) | ID of the public IP address to use for the frontend IP configuration. | `string` | `null` | no |
| <a name="input_frontend_private_ip_configuration_name"></a> [frontend\_private\_ip\_configuration\_name](#input\_frontend\_private\_ip\_configuration\_name) | Name of the frontend private IP configuration. | `string` | `null` | no |
| <a name="input_gateway_ip_configuration_name"></a> [gateway\_ip\_configuration\_name](#input\_gateway\_ip\_configuration\_name) | Name of the gateway IP configuration. | `string` | n/a | yes |
| <a name="input_sku_capacity"></a> [sku\_capacity](#input\_sku\_capacity) | The Capacity of the SKU to use for this Application Gateway - which must be between 1 and 10, optional if autoscale\_configuration is set | `number` | `2` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The Name of the SKU to use for this Application Gateway. Possible values are Standard\_v2 and WAF\_v2. | `string` | `"Standard_v2"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | A collection of availability zones to spread the Application Gateway over. This option is only supported for v2 SKUs | `list(number)` | <pre>[<br>  1,<br>  2,<br>  3<br>]</pre> | no |
| <a name="input_frontend_port_settings"></a> [frontend\_port\_settings](#input\_frontend\_port\_settings) | Frontend port settings. Each port setting contains the name and the port for the frontend port. | <pre>list(object({<br>    name = string<br>    port = number<br>  }))</pre> | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | Application Gateway SSL configuration. The list of available policies can be found here: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#disabled_protocols | <pre>object({<br>    disabled_protocols   = optional(list(string), [])<br>    policy_type          = optional(string, "Predefined")<br>    policy_name          = optional(string, "AppGwSslPolicy20170401S")<br>    cipher_suites        = optional(list(string), [])<br>    min_protocol_version = optional(string, "TLSv1_2")<br>  })</pre> | `null` | no |
| <a name="input_ssl_profile"></a> [ssl\_profile](#input\_ssl\_profile) | Application Gateway SSL profile. Default profile is used when this variable is set to null. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#name | <pre>list(object({<br>    name                             = string<br>    trusted_client_certificate_names = optional(list(string), [])<br>    verify_client_cert_issuer_dn     = optional(bool, false)<br>    ssl_policy = optional(object({<br>      disabled_protocols   = optional(list(string), [])<br>      policy_type          = optional(string, "Predefined")<br>      policy_name          = optional(string, "AppGwSslPolicy20170401S")<br>      cipher_suites        = optional(list(string), [])<br>      min_protocol_version = optional(string, "TLSv1_2")<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | ID of a Web Application Firewall Policy | `string` | `null` | no |
| <a name="input_trusted_root_certificate_configs"></a> [trusted\_root\_certificate\_configs](#input\_trusted\_root\_certificate\_configs) | List of trusted root certificates. `file_path` is checked first, using `data` (base64 cert content) if null. This parameter is required if you are not using a trusted certificate authority (eg. selfsigned certificate). | <pre>list(object({<br>    name                = string<br>    data                = optional(string)<br>    file_path           = optional(string)<br>    key_vault_secret_id = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_appgw_backend_pools"></a> [appgw\_backend\_pools](#input\_appgw\_backend\_pools) | List of objects with backend pool configurations. | <pre>list(object({<br>    name         = string<br>    fqdns        = optional(list(string))<br>    ip_addresses = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_appgw_http_listeners"></a> [appgw\_http\_listeners](#input\_appgw\_http\_listeners) | List of objects with HTTP listeners configurations and custom error configurations.<br>    The field `frontend_ip_configuration_name` may not be set. By default, the listener attaches to the public IP of the App Gateway.<br>    If appgw\_private is set to true, the listener will attach to the private IP of the App Gateway.<br>    If user needs to override this behavior, they can set the `frontend_ip_configuration_name` to the name of the frontend IP configuration. | <pre>list(object({<br>    name = string<br><br>    frontend_ip_configuration_name = optional(string)<br>    frontend_port_name             = optional(string)<br>    host_name                      = optional(string)<br>    host_names                     = optional(list(string))<br>    protocol                       = optional(string, "Https")<br>    require_sni                    = optional(bool, false)<br>    ssl_certificate_name           = optional(string)<br>    ssl_profile_name               = optional(string)<br>    firewall_policy_id             = optional(string)<br><br>    custom_error_configuration = optional(list(object({<br>      status_code           = string<br>      custom_error_page_url = string<br>    })), [])<br>  }))</pre> | n/a | yes |
| <a name="input_custom_error_configuration"></a> [custom\_error\_configuration](#input\_custom\_error\_configuration) | List of objects with global level custom error configurations. | <pre>list(object({<br>    status_code           = string<br>    custom_error_page_url = string<br>  }))</pre> | `[]` | no |
| <a name="input_ssl_certificates_configs"></a> [ssl\_certificates\_configs](#input\_ssl\_certificates\_configs) | List of objects with SSL certificates configurations.<br>The path to a base-64 encoded certificate is expected in the 'data' attribute:<pre>data = filebase64("./file_path")</pre> | <pre>list(object({<br>    name                = string<br>    data                = optional(string)<br>    password            = optional(string)<br>    key_vault_secret_id = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_authentication_certificates_configs"></a> [authentication\_certificates\_configs](#input\_authentication\_certificates\_configs) | List of objects with authentication certificates configurations.<br>The path to a base-64 encoded certificate is expected in the 'data' attribute:<pre>data = filebase64("./file_path")</pre> | <pre>list(object({<br>    name = string<br>    data = string<br>  }))</pre> | `[]` | no |
| <a name="input_trusted_client_certificates_configs"></a> [trusted\_client\_certificates\_configs](#input\_trusted\_client\_certificates\_configs) | List of objects with trusted client certificates configurations.<br>The path to a base-64 encoded certificate is expected in the 'data' attribute:<pre>data = filebase64("./file_path")</pre> | <pre>list(object({<br>    name = string<br>    data = string<br>  }))</pre> | `[]` | no |
| <a name="input_appgw_routings"></a> [appgw\_routings](#input\_appgw\_routings) | List of objects with request routing rules configurations. With AzureRM v3+ provider, `priority` attribute becomes mandatory. | <pre>list(object({<br>    name                        = string<br>    rule_type                   = optional(string, "Basic")<br>    http_listener_name          = optional(string)<br>    backend_address_pool_name   = optional(string)<br>    backend_http_settings_name  = optional(string)<br>    url_path_map_name           = optional(string)<br>    redirect_configuration_name = optional(string)<br>    rewrite_rule_set_name       = optional(string)<br>    priority                    = optional(number)<br>  }))</pre> | n/a | yes |
| <a name="input_appgw_probes"></a> [appgw\_probes](#input\_appgw\_probes) | List of objects with probes configurations. | <pre>list(object({<br>    name     = string<br>    host     = optional(string)<br>    port     = optional(number, null)<br>    interval = optional(number, 30)<br>    path     = optional(string, "/")<br>    protocol = optional(string, "Https")<br>    timeout  = optional(number, 30)<br><br>    unhealthy_threshold                       = optional(number, 3)<br>    pick_host_name_from_backend_http_settings = optional(bool, false)<br>    minimum_servers                           = optional(number, 0)<br><br>    match = optional(object({<br>      body        = optional(string, "")<br>      status_code = optional(list(string), ["200-399"])<br>    }), {})<br>  }))</pre> | `[]` | no |
| <a name="input_appgw_backend_http_settings"></a> [appgw\_backend\_http\_settings](#input\_appgw\_backend\_http\_settings) | List of objects including backend http settings configurations. | <pre>list(object({<br>    name     = string<br>    port     = optional(number, 443)<br>    protocol = optional(string, "Https")<br><br>    path       = optional(string)<br>    probe_name = optional(string)<br><br>    cookie_based_affinity               = optional(string, "Disabled")<br>    affinity_cookie_name                = optional(string, "ApplicationGatewayAffinity")<br>    request_timeout                     = optional(number, 20)<br>    host_name                           = optional(string)<br>    pick_host_name_from_backend_address = optional(bool, true)<br>    trusted_root_certificate_names      = optional(list(string), [])<br>    authentication_certificate          = optional(string)<br><br>    connection_draining_timeout_sec = optional(number)<br>  }))</pre> | n/a | yes |
| <a name="input_appgw_url_path_map"></a> [appgw\_url\_path\_map](#input\_appgw\_url\_path\_map) | List of objects with URL path map configurations. | <pre>list(object({<br>    name = string<br><br>    default_backend_address_pool_name   = optional(string)<br>    default_redirect_configuration_name = optional(string)<br>    default_backend_http_settings_name  = optional(string)<br>    default_rewrite_rule_set_name       = optional(string)<br><br>    path_rules = list(object({<br>      name = string<br><br>      backend_address_pool_name   = optional(string)<br>      backend_http_settings_name  = optional(string)<br>      rewrite_rule_set_name       = optional(string)<br>      redirect_configuration_name = optional(string)<br><br>      paths = optional(list(string), [])<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_appgw_redirect_configuration"></a> [appgw\_redirect\_configuration](#input\_appgw\_redirect\_configuration) | List of objects with redirect configurations. | <pre>list(object({<br>    name = string<br><br>    redirect_type        = optional(string, "Permanent")<br>    target_listener_name = optional(string)<br>    target_url           = optional(string)<br><br>    include_path         = optional(bool, true)<br>    include_query_string = optional(bool, true)<br>  }))</pre> | `[]` | no |
| <a name="input_appgw_rewrite_rule_set"></a> [appgw\_rewrite\_rule\_set](#input\_appgw\_rewrite\_rule\_set) | List of rewrite rule set objects with rewrite rules. | <pre>list(object({<br>    name = string<br>    rewrite_rules = list(object({<br>      name          = string<br>      rule_sequence = string<br><br>      conditions = optional(list(object({<br>        variable    = string<br>        pattern     = string<br>        ignore_case = optional(bool, false)<br>        negate      = optional(bool, false)<br>      })), [])<br><br>      response_header_configurations = optional(list(object({<br>        header_name  = string<br>        header_value = string<br>      })), [])<br><br>      request_header_configurations = optional(list(object({<br>        header_name  = string<br>        header_value = string<br>      })), [])<br><br>      url_reroute = optional(object({<br>        path         = optional(string)<br>        query_string = optional(string)<br>        components   = optional(string)<br>        reroute      = optional(bool)<br>      }))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_force_firewall_policy_association"></a> [force\_firewall\_policy\_association](#input\_force\_firewall\_policy\_association) | Enable if the Firewall Policy is associated with the Application Gateway. | `bool` | `false` | no |
| <a name="input_waf_configuration"></a> [waf\_configuration](#input\_waf\_configuration) | WAF configuration object (only available with WAF\_v2 SKU) with following attributes:<pre>- enabled:                  Boolean to enable WAF.<br>- file_upload_limit_mb:     The File Upload Limit in MB. Accepted values are in the range 1MB to 500MB.<br>- firewall_mode:            The Web Application Firewall Mode. Possible values are Detection and Prevention.<br>- max_request_body_size_kb: The Maximum Request Body Size in KB. Accepted values are in the range 1KB to 128KB.<br>- request_body_check:       Is Request Body Inspection enabled ?<br>- rule_set_type:            The Type of the Rule Set used for this Web Application Firewall.<br>- rule_set_version:         The Version of the Rule Set used for this Web Application Firewall. Possible values are 2.2.9, 3.0, and 3.1.<br>- disabled_rule_group:      The rule group where specific rules should be disabled. Accepted values can be found here: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#rule_group_name<br>- exclusion:                WAF exclusion rules to exclude header, cookie or GET argument. More informations on: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#match_variable</pre> | <pre>object({<br>    enabled                  = optional(bool, true)<br>    file_upload_limit_mb     = optional(number, 100)<br>    firewall_mode            = optional(string, "Prevention")<br>    max_request_body_size_kb = optional(number, 128)<br>    request_body_check       = optional(bool, true)<br>    rule_set_type            = optional(string, "OWASP")<br>    rule_set_version         = optional(string, 3.1)<br>    disabled_rule_group = optional(list(object({<br>      rule_group_name = string<br>      rules           = optional(list(string))<br>    })), [])<br>    exclusion = optional(list(object({<br>      match_variable          = string<br>      selector                = optional(string)<br>      selector_match_operator = optional(string)<br>    })), [])<br>  })</pre> | `{}` | no |
| <a name="input_disable_waf_rules_for_dev_portal"></a> [disable\_waf\_rules\_for\_dev\_portal](#input\_disable\_waf\_rules\_for\_dev\_portal) | Whether to disable some WAF rules if the APIM developer portal is hosted behind this Application Gateway. See locals.tf for the documentation link. | `bool` | `false` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Custom subnet ID for attaching the Application Gateway. Used only when the variable `create_subnet = false`. | `string` | `""` | no |
| <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address) | The private IP address of the Application Gateway. Must be within the range of the subnet. Required only when appgw\_private is set to true. | `string` | `""` | no |
| <a name="input_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#input\_user\_assigned\_identity\_id) | User assigned identity id assigned to this resource. | `string` | `null` | no |
| <a name="input_appgw_private"></a> [appgw\_private](#input\_appgw\_private) | Boolean variable to create a private Application Gateway. When `true`, the default http listener will listen on private IP instead of the public IP. | `bool` | `false` | no |
| <a name="input_appgw_private_ip"></a> [appgw\_private\_ip](#input\_appgw\_private\_ip) | Private IP for Application Gateway. Used when variable `appgw_private` is set to `true`. | `string` | `null` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Whether to enable http2 or not | `bool` | `true` | no |
| <a name="input_autoscaling_parameters"></a> [autoscaling\_parameters](#input\_autoscaling\_parameters) | Map containing autoscaling parameters. Must contain at least min\_capacity | <pre>object({<br>    min_capacity = number<br>    max_capacity = optional(number, 5)<br>  })</pre> | `null` | no |
| <a name="input_create_user_managed_identity"></a> [create\_user\_managed\_identity](#input\_create\_user\_managed\_identity) | Creates an user assigned managed Identity and assigns it to the Application Gateway | `bool` | `true` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of role assignments to be associated with the user assigned managed identity of the Application Gateway<br>    Should be of the format<br>    {<br>      private-dns = ["Private DNS Zone Contributor", "<private-dns-zone-id>"]<br>      key-vault = ["Key Vault Administrator", "<key-vault-id>"]<br>    } | `map(list(string))` | `{}` | no |
| <a name="input_custom_private_dns_record"></a> [custom\_private\_dns\_record](#input\_custom\_private\_dns\_record) | Custom private DNS record for the Application Gateway. An A-record would be created for the private IP address | <pre>object({<br>    name                  = string<br>    ttl                   = optional(number, 300)<br>    private_dns_zone_name = string<br>    private_dns_zone_rg   = string<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Application Gateway. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Application Gateway. |
| <a name="output_frontend_ip_configuration"></a> [frontend\_ip\_configuration](#output\_frontend\_ip\_configuration) | The frontend IP configuration of the Application Gateway. |
| <a name="output_frontend_port"></a> [frontend\_port](#output\_frontend\_port) | The frontend port of the Application Gateway. |
| <a name="output_backend_address_pool"></a> [backend\_address\_pool](#output\_backend\_address\_pool) | The backend address pool of the Application Gateway. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
