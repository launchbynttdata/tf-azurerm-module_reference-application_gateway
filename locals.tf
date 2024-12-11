locals {
  default_tags = {
    "provisioner" = "Terraform"
  }
  tags = merge(local.default_tags, var.tags)

  use_v2_resource_names = (var.resource_names_version == "2")
}
