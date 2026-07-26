# Applications

## Overview

This directory contains application source code, deployment configurations, and environment-specific artifacts used by the platform.

Applications are built through CI/CD pipelines and deployed to Amazon EKS using ArgoCD.

---

## Deployment Flow

```text
Developer Commit
        │
        ▼
GitHub Repository
        │
        ▼
GitHub Actions
        │
        ▼
Docker Image Build
        │
        ▼
Docker HUB 
        │
        ▼
ArgoCD
        │
        ▼
Amazon EKS
```

---

## Application Lifecycle

### Source Control

Application code is maintained in Git repositories.

### Continuous Integration

The CI pipeline performs:

- Source code checkout
- Dependency installation
- Unit testing
- Docker image build
- Container image push to Docker Hub

### Continuous Delivery

ArgoCD continuously monitors deployment manifests and synchronizes workloads to Kubernetes clusters.

---

## Environment Strategy

Applications are deployed independently across environments.

| Environment | Cluster |
|-------------|-----------|
| Development | EKS Dev |
| QA | EKS QA |
| Production | EKS Prod |

---

## Container Registry

Application images are stored in Docker Hub.

Example:

```text
shivamaglwork/node-app
```

---

## Kubernetes Deployment

Applications are deployed using:

- ArgoCD Applications
- Kustomize

Deployment manifests are maintained separately from infrastructure code.

---

## Monitoring

Application metrics are collected through:

- Prometheus
- Grafana

Available metrics include:

- CPU Usage
- Memory Usage
- Pod Health
- Request Rates
- Error Rates
- Response Times

---

## Platform Integrations

| Service | Purpose |
|----------|----------|
| GitHub | Source Control |
| GitHub Actions | CI/CD |
| Docker HUB | Container Registry |
| ArgoCD | GitOps Deployment |
| Amazon EKS | Container Platform |
| Prometheus | Metrics Collection |
| Grafana | Visualization |

---

## Deployment Verification

Verify application status:

```bash
kubectl get pods -n frontend
```

Verify ArgoCD synchronization:

```bash
argocd app list
```

Verify image version:

```bash
kubectl describe deployment <deployment-name> -n namespace_name
```

---