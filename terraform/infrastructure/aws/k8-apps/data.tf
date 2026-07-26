# ------------------------------------------------
# CURRENT AWS REGION
# ------------------------------------------------

data "aws_region" "current" {}

# ------------------------------------------------
# CURRENT ACCOUNT
# ------------------------------------------------

data "aws_caller_identity" "current" {}

# ------------------------------------------------
# EKS CLUSTER
# ------------------------------------------------

data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

# ------------------------------------------------
# EKS AUTH
# ------------------------------------------------

data "aws_eks_cluster_auth" "this" {
  name = local.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# ------------------------------------------------
# VPC
# ------------------------------------------------

data "aws_vpc" "this" {
  id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}