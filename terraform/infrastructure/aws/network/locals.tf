locals {
  env = terraform.workspace

  vpc_config = try(var.vpcs[local.env][var.aws_region], null)
}

resource "terraform_data" "validate_workspace" {
  lifecycle {
    precondition {
      condition     = local.vpc_config != null
      error_message = "No VPC config found for workspace '${local.env}' and region '${var.aws_region}' in var.vpcs."
    }
  }
}