locals {
  env    = terraform.workspace
  region = var.aws_region

  eks_config = var.eks_clusters[local.env][local.region]

  vpc_name = "${local.env}-vpc"
}