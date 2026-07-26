# SimpleTimeService

A minimal Node.js microservice that returns the current timestamp and the visitor's IP address as JSON, containerized and deployed to AWS EKS using Terraform.

```json
{
  "timestamp": "2026-07-26T10:00:00.000Z",
  "ip": "203.0.113.5"
}
```

## Repository Structure

```
.
├── app/                        # Application source code + Dockerfile
├── terraform/infrastructure/   # Terraform code (networking, EKS, ALB, app deployment)
└── .github/workflows/          # CI/CD pipeline (build, test, push image)
```

## Architecture

- **VPC** with public and private subnets across multiple Availability Zones.
- **Amazon EKS** cluster — application pods run in **private subnets only**.
- **AWS Load Balancer Controller** provisions an **Application Load Balancer (ALB)** in the public subnets via a Kubernetes Ingress, exposing the app to the internet.
- **NAT Gateway** in the public subnet allows private-subnet workloads outbound internet access (image pulls, package updates) without being publicly reachable themselves.
- **Container image** is published to Docker Hub and pulled by the cluster at deploy time.

### Why this architecture

EKS was chosen over a simpler option (e.g. plain EC2 or ECS) to demonstrate production-grade, cloud-native infrastructure: Kubernetes gives us declarative rollouts, self-healing, and a clear path to add autoscaling, health checks, and further workloads without re-architecting. The ALB + Ingress pattern (Layer 7) is used instead of a plain Service LoadBalancer (Layer 4/NLB) because it supports host/path-based routing, TLS termination, and is the AWS-recommended pattern for exposing HTTP workloads running in private subnets.

## Prerequisites

Before deploying, make sure you have:

1. **An AWS account** with permissions to create VPC, EKS, IAM, ALB, S3, and DynamoDB resources.
2. **An IAM user/role with programmatic access** (Access Key ID + Secret Access Key).
3. **An S3 bucket** to store Terraform remote state (create this once, manually, before running Terraform — see below).
4. **A DynamoDB table** for Terraform state locking (create this once, manually, before running Terraform — see below).
5. The following tools installed locally:

| Tool | Purpose | Install Guide |
|---|---|---|
| AWS CLI v2 | Authenticate to AWS | https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html |
| Terraform (>= 1.6) | Provision infrastructure | https://developer.hashicorp.com/terraform/install |
| kubectl | Interact with the EKS cluster | https://kubernetes.io/docs/tasks/tools/install-kubectl/ |
| Helm | (Optional) install cluster add-ons | https://helm.sh/docs/intro/install/ |
| Docker | Build/test the container image locally | https://docs.docker.com/get-docker/ |

### Install AWS CLI (Linux)
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

### Install Terraform (Ubuntu/Debian)
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
terraform -version
```

### Install kubectl (Ubuntu/Debian)
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install kubectl -y
kubectl version --client
```

### Install Helm (Ubuntu/Debian)
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh
./get_helm.sh
helm version
```

## One-Time Setup: Remote State Backend

Terraform state and locking require an S3 bucket and a DynamoDB table. Create these **once**, before running `terraform apply` (they are outside the scope of the Terraform code itself, to avoid a chicken-and-egg problem with state storage).

**Create the S3 bucket** (bucket names must be globally unique):
```bash
aws s3api create-bucket \
  --bucket <your-unique-bucket-name> \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket <your-unique-bucket-name> \
  --versioning-configuration Status=Enabled
```

**Create the DynamoDB lock table:**
```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Then update the backend configuration in `terraform/infrastructure/backend.tf` (or equivalent) with your bucket and table names:
```hcl
terraform {
  backend "s3" {
    bucket         = "<your-unique-bucket-name>"
    key            = "simpletimeservice/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## Authenticate to AWS

Configure your AWS credentials so Terraform and the AWS CLI can authenticate:

```bash
aws configure
```
You'll be prompted for:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g. `us-east-1`)
- Default output format (e.g. `json`)

Alternatively, export credentials as environment variables:
```bash
export AWS_ACCESS_KEY_ID="<your-access-key-id>"
export AWS_SECRET_ACCESS_KEY="<your-secret-access-key>"
export AWS_DEFAULT_REGION="us-east-1"
```

> **Never commit AWS credentials to the repository.** Use `aws configure`, environment variables, or an AWS profile — not hardcoded values in `.tf` files.

## Deploying the Infrastructure

```bash
cd terraform/infrastructure

terraform init
terraform plan
terraform apply
```

Type `yes` when prompted. This will provision the VPC, EKS cluster, ALB Ingress Controller, and deploy the application — end to end.

Default values for all variables are provided in `terraform.tfvars`. Override any of them with `-var` flags or by editing `terraform.tfvars` directly.

## Accessing the Application

Once `terraform apply` completes, retrieve the ALB DNS name:

```bash
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>
kubectl get ingress -n <namespace>
```

Access the app:
```bash
curl http://<alb-dns-name>/
```

Expected response:
```json
{
  "timestamp": "2026-07-26T10:00:00.000Z",
  "ip": "203.0.113.5"
}
```

## Container Image

The image is publicly available on Docker Hub:
```
docker pull <dockerhub-username>/<image-name>:latest
```

- Runs as a **non-root user** inside the container.
- Built on a minimal Alpine base to keep image size small.

## CI/CD

A GitHub Actions workflow (`.github/workflows/`) automatically:
1. Runs the test suite on every push to `main`.
2. Builds the Docker image.
3. Pushes it to Docker Hub, tagged with the 8-character short commit SHA and `latest`.

## Tearing Down

To avoid ongoing AWS charges, destroy all provisioned resources when done:
```bash
cd terraform/infrastructure
terraform destroy
```

You are responsible for manually deleting the S3 bucket and DynamoDB table created in the one-time setup step, if no longer needed:
```bash
aws s3 rb s3://<your-unique-bucket-name> --force
aws dynamodb delete-table --table-name terraform-locks
```

## Notes

- This project was built as a solution to a DevOps take-home challenge, demonstrating containerization, IaC, and cloud networking best practices.
- All infrastructure is provisioned via `terraform plan` / `terraform apply` only — no manual console steps are required beyond the one-time backend setup described above.
