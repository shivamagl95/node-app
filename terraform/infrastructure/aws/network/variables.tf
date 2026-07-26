variable "vpcs" {
  description = "Map of VPC configs by workspace and region"
  type = map(
    map(
      object({
        cidr_block        = string
        public_subnets    = list(string)
        private_subnets   = list(string)
        availability_zones = list(string)
        enable_nat_gateway = bool
        single_nat_gateway = bool
        tags              = map(string)
      })
    )
  )
}