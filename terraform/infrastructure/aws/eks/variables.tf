variable "eks_clusters" {
  description = "Map of EKS configs by workspace and region"
  type = map(
    map(
      object({
        cluster_name                     = string
        cluster_version                  = string
        vpc_name                         = string
        private_subnet_names             = list(string)
        public_subnet_names              = list(string)
        kubernetes_admin_arns            = list(string)
        endpoint_public_access           = bool
        endpoint_private_access          = bool
        node_group_name                  = string
        node_instance_types              = list(string)
        desired_size                     = number
        min_size                         = number
        max_size                         = number
        capacity_type                    = string
        disk_size                        = number
        cluster_addons = map(object({
          addon_version               = optional(string)
          resolve_conflicts_on_create = optional(string)
          resolve_conflicts_on_update = optional(string)
          service_account_role_arn    = optional(string)
          preserve                    = optional(bool)
          most_recent                 = optional(bool)
        }))
        tags = map(string)
      })
    )
  )
}