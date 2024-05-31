# // Licensed under the Apache License, Version 2.0 (the "License");
# // you may not use this file except in compliance with the License.
# // You may obtain a copy of the License at
# //
# //     http://www.apache.org/licenses/LICENSE-2.0
# //
# // Unless required by applicable law or agreed to in writing, software
# // distributed under the License is distributed on an "AS IS" BASIS,
# // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# // See the License for the specific language governing permissions and
# // limitations under the License.

output "id" {
  value       = module.application_gateway.id
  description = "The ID of the Application Gateway."
}

output "name" {
  value       = module.application_gateway.name
  description = "The name of the Application Gateway."
}

output "frontend_ip_configuration" {
  description = "The frontend IP configuration of the Application Gateway."
  value       = module.application_gateway.frontend_ip_configuration
}

output "frontend_port" {
  description = "The frontend port of the Application Gateway."
  value       = module.application_gateway.frontend_port
}

output "backend_address_pool" {
  description = "The backend address pool of the Application Gateway."
  value       = module.application_gateway.backend_address_pool
}
