module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.eks_config.cluster_name
  cluster_version = local.eks_config.cluster_version

  vpc_id = data.aws_vpc.this.id

  # Control Plane in Public Subnets (for public access)
  control_plane_subnet_ids = data.aws_subnets.public.ids

  # Worker Nodes in Private Subnets
  subnet_ids = data.aws_subnets.private.ids

  cluster_endpoint_public_access  = local.eks_config.endpoint_public_access
  cluster_endpoint_private_access = local.eks_config.endpoint_private_access

  authentication_mode = "API_AND_CONFIG_MAP"

  # Admin Access
  access_entries = {
    admin = {
      principal_arn = local.eks_config.kubernetes_admin_arns[0]
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  # Managed Node Group - Private Subnets
  eks_managed_node_groups = {
    (local.eks_config.node_group_name) = {
      name           = local.eks_config.node_group_name
      instance_types = local.eks_config.node_instance_types
      capacity_type  = local.eks_config.capacity_type

      min_size     = local.eks_config.min_size
      max_size     = local.eks_config.max_size
      desired_size = local.eks_config.desired_size
      disk_size    = local.eks_config.disk_size

      subnet_ids = data.aws_subnets.private.ids   # ← Private only

      labels = {
        Environment = local.env
      }

      tags = merge(
        local.eks_config.tags,
        {
          "k8s.io/cluster-autoscaler/enabled"                      = "true"
          "k8s.io/cluster-autoscaler/${local.eks_config.cluster_name}" = "owned"
        }
      )
    }
  }

  # Addons
  cluster_addons = {
    for k, v in local.eks_config.cluster_addons : k => {
      most_recent                 = v.most_recent
      resolve_conflicts_on_create = v.resolve_conflicts_on_create
      resolve_conflicts_on_update = v.resolve_conflicts_on_update
    }
  }

  tags = local.eks_config.tags
}