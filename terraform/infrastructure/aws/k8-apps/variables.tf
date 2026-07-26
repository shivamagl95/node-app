variable "namespaces" {

  description = "Kubernetes namespaces"

  type = set(string)

  default = [
    "logging",
    "monitoring",
    "frontend"
  ]
}