module "lb_controller_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.50"

  role_name = "${local.cluster_name}-aws-lb-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn = data.aws_iam_openid_connect_provider.this.arn

      namespace_service_accounts = [
        "kube-system:aws-load-balancer-controller"
      ]
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "3.3.0"

  values = [
    yamlencode({

      clusterName = local.cluster_name

      region = data.aws_region.current.name

      vpcId = data.aws_vpc.this.id

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.lb_controller_role.iam_role_arn
        }
      }

      replicaCount = 2
    })
  ]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  version = "9.5.19"

  create_namespace = false

  values = [
    yamlencode({

      configs = {
        cm = {
          "accounts.admin" = "apiKey, login"
        }
        params = {
          "server.insecure" = true
        }
      }

      server = {

        service = {
          type = "ClusterIP"
        }
        ingress = {
          enabled = false
        }
      }
    })
  ]
}

resource "kubernetes_ingress_v1" "argocd" {

  metadata {

    name      = "argocd"
    namespace = "argocd"

    annotations = {

      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\":80}]"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.13.0"
}

resource "kubernetes_namespace" "this" {
  for_each = var.namespaces
  metadata {
    name = each.value
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "${terraform.workspace}-monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  values = [
    yamlencode({
      grafana = {
        service = {
          type = "LoadBalancer"
        }
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
            "alb.ingress.kubernetes.io/target-type" = "ip"
          }
        }
      }

      prometheus = {
        prometheusSpec = {
          retention = "7d"
        }
      }
    })
  ]
}