module "vpc" {
  source = "../../modules/network/"

  name               = "${terraform.workspace}-vpc"
  env                = terraform.workspace
  region             = var.aws_region
  cidr_block         = local.vpc_config.cidr_block
  availability_zones = local.vpc_config.availability_zones

  public_subnets     = local.vpc_config.public_subnets
  private_subnets    = local.vpc_config.private_subnets

  enable_nat_gateway = local.vpc_config.enable_nat_gateway
  single_nat_gateway = local.vpc_config.single_nat_gateway

  tags = merge(
    {
      Environment = terraform.workspace
      Region      = var.aws_region
      Terraform   = "true"
    },
    local.vpc_config.tags
  )

  depends_on = [terraform_data.validate_workspace]
}