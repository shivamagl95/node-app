# Network Infrastructure

## Purpose

Provision foundational networking resources required by all platform services.

## Resources Created

- VPC
- Public Subnets
- Private Subnets
- Route Tables
- Internet Gateway
- NAT Gateway
- Security Groups

## Deployment

```bash
terraform init
terraform plan -var-file=../../vars/global-network.tfvars
terraform apply -var-file=../../vars/global-network.tfvars
```

## Outputs

- VPC ID
- Public Subnet IDs
- Private Subnet IDs
- Route Table IDs
- Security Group IDs

## Dependencies

None