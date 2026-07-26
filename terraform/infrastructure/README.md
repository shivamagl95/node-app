# Infrastructure Setup for 3 tier Application

## Overview

This repository contains Terraform code used to provision and manage AWS infrastructure resources.

The infrastructure is organized into independent domains to simplify deployment, maintenance, and ownership.

## Repository Structure

```text
infrastructure/
├── aws/
│   ├── network/
│   ├── ecr/
│   ├── eks/
│   ├── rds/
│   ├── cloudfront/
│   ├── observability/
│   └── k8-apps/
├── modules/
├── vars/
└── apps/
```

## Components

| Component | Description |
|------------|-------------|
| network | VPC, Subnets, Route Tables, NAT Gateways, Security Groups |
| ecr | Elastic Container Registry repositories |
| eks | Amazon EKS clusters and node groups |
| rds | Amazon RDS databases |
| cloudfront | CDN distributions and caching |
| observability | Prometheus, Grafana and monitoring stack |
| k8-apps | Kubernetes add-ons and platform applications |

## Deployment Order

1. Network
2. ECR
3. RDS
4. EKS
5. Observability
6. Kubernetes Applications
7. CloudFront

## Prerequisites

- Terraform >= 1.5
- AWS CLI
- kubectl
- Helm
- AWS IAM permissions

## Architecture

![AWS Infrastructure Architecture](docs/arch.png)

## Terraform Commands

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Destroy:

```bash
terraform destroy
```

## State Management

Terraform state is stored remotely using the backend configuration defined within each module on s3. 

## Environment Management

This repository uses Terraform Workspaces to manage environment-specific deployments.

Each environment must have a corresponding workspace:

| Environment | Workspace |
|-------------|------------|
| Development | dev |
| QA | qa |
| Production | prod |

Before running any Terraform commands, ensure the correct workspace is selected.

Create a workspace:

```bash
terraform workspace new dev
terraform workspace new qa
terraform workspace new prod
```

Select a workspace:

```bash
terraform workspace select dev
```

Verify current workspace:

```bash
terraform workspace show
```

Note: Resource naming is workspace-aware and resources are provisioned separately for each environment.

## Currently Deployed Resources

The following URLs provide access to deployed platform components.

| Service | Environment | URL |
|----------|------------|-----|
| Frontend Application | Dev | http://k8s-frontend-frontend-a7dacf80be-b430be2625566a75.elb.us-east-1.amazonaws.com/ |
| Backend API | Dev | http://k8s-backend-backenda-d8ef9051fa-3bbfdb834e5c9045.elb.us-east-1.amazonaws.com/api/status |
| ArgoCD | Dev | http://k8s-argocd-argocd-35c95ecac2-417860683.us-east-1.elb.amazonaws.com/ |
| Grafana | Dev | http://k8s-monitori-monitori-51c2eca274-f30e06f028c62e22.elb.us-east-1.amazonaws.com/ |
| SonarQube | Dev | http://3.84.131.37:9000/ |