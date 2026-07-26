locals {
  env    = terraform.workspace
  region = var.aws_region
  vpc_name = "${local.env}-vpc"
}