aws_region = "us-east-1"

eks_clusters = {
  dev = {
    us-east-1 = {
      cluster_name            = "dev-eks"
      cluster_version         = "1.34"
      vpc_name                = "dev-vpc"
      private_subnet_names    = ["dev-vpc-private-1", "dev-vpc-private-2"]
      public_subnet_names     = ["dev-vpc-public-1", "dev-vpc-public-2"]
      kubernetes_admin_arns   = ["arn:aws:iam::526741672110:user/terraform"]
      endpoint_public_access  = true
      endpoint_private_access = false
      node_group_name         = "dev-ng"
      node_instance_types     = ["t3.medium"]
      desired_size            = 1
      min_size                = 1
      max_size                = 1
      capacity_type           = "ON_DEMAND"
      disk_size               = 30

      cluster_addons = {
        coredns = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
        kube-proxy = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
        vpc-cni = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
        eks-pod-identity-agent = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
      }

      tags = {
        Project     = "eks"
        Environment = "dev"
      }
    }
  }

  stg = {
    us-east-1 = {
      cluster_name            = "stg-public-eks"
      cluster_version         = "1.34"
      vpc_name                = "stg-vpc"
      private_subnet_names    = ["stg-vpc-private-1", "stg-vpc-private-2"]
      public_subnet_names     = ["stg-vpc-public-1", "stg-vpc-public-2"]
      kubernetes_admin_arns   = ["arn:aws:iam::526741672110:user/terraform"]
      endpoint_public_access  = true
      endpoint_private_access = false
      node_group_name         = "stg-ng"
      node_instance_types     = ["t3.medium"]
      desired_size            = 2
      min_size                = 2
      max_size                = 2
      capacity_type           = "ON_DEMAND"
      disk_size               = 30

      cluster_addons = {
        coredns = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
        kube-proxy = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
        vpc-cni = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
        eks-pod-identity-agent = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
      }

      tags = {
        Project     = "eks"
        Environment = "stg"
      }
    }
  }

  prod = {
    us-east-1 = {
      cluster_name            = "prod-public-eks"
      cluster_version         = "1.34"
      vpc_name                = "prod-vpc"
      private_subnet_names    = ["prod-vpc-private-1", "prod-vpc-private-2"]
      public_subnet_names     = ["prod-vpc-public-1", "prod-vpc-public-2"]
      kubernetes_admin_arns   = ["arn:aws:iam::526741672110:user/terraform"]
      endpoint_public_access  = true
      endpoint_private_access = false
      node_group_name         = "prod-ng"
      node_instance_types     = ["t3.medium"]
      desired_size            = 2
      min_size                = 2
      max_size                = 2
      capacity_type           = "ON_DEMAND"
      disk_size               = 50

      cluster_addons = {
        coredns = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
        kube-proxy = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
        vpc-cni = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
        eks-pod-identity-agent = {
          most_recent                 = true
          resolve_conflicts_on_create = "OVERWRITE"
          resolve_conflicts_on_update = "OVERWRITE"
        }
      }

      tags = {
        Project     = "eks"
        Environment = "prod"
      }
    }
  }
}