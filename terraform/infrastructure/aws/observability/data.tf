# ------------------------------------------------
# CURRENT AWS REGION
# ------------------------------------------------

data "aws_region" "current" {}

# ------------------------------------------------
# CURRENT ACCOUNT
# ------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    Tier = "public"
  }
}

# ==================== Latest Ubuntu 24.04 AMI ====================
data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"]   # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}