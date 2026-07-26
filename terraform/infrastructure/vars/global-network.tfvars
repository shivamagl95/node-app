aws_region = "us-east-1"

vpcs = {
  dev = {
    us-east-1 = {
      cidr_block         = "10.10.0.0/16"
      availability_zones = ["us-east-1a", "us-east-1b"]

      public_subnets     = ["10.10.1.0/24", "10.10.2.0/24"]
      private_subnets    = ["10.10.11.0/24", "10.10.12.0/24"]
      

      enable_nat_gateway = true
      single_nat_gateway = true

      tags = {
        Project = "dev"
        Owner   = "shivam"
      }
    }
  }

  stg = {
    us-east-1 = {
      cidr_block         = "10.20.0.0/16"
      availability_zones = ["us-east-1a", "us-east-1b"]

      public_subnets     = ["10.20.1.0/24", "10.20.2.0/24"]
      private_subnets    = ["10.20.11.0/24", "10.20.12.0/24"]

      enable_nat_gateway = true
      single_nat_gateway = true

      tags = {
        Project = "stg"
        Owner   = "shivam"
      }
    }
  }

  prod = {
    us-east-1 = {
      cidr_block         = "10.30.0.0/16"
      availability_zones = ["us-east-1a", "us-east-1b"]

      public_subnets     = ["10.30.1.0/24", "10.30.2.0/24"]
      private_subnets    = ["10.30.11.0/24", "10.30.12.0/24"]

      enable_nat_gateway = true
      single_nat_gateway = false

      tags = {
        Project = "prod"
        Owner   = "shivam"
      }
    }
  }
}