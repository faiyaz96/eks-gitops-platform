# 🚀 Project Overview: GitOps Workflow for EKS Using Terraform & Kubernetes

This project implements a complete **GitOps-style CI/CD workflow** to manage both infrastructure and applications in AWS using **Terraform**, **Kubernetes**, and **GitHub Actions**. It ensures consistent, automated, and auditable deployments across environments.

---

## 📑 Table of Contents

* [Infrastructure Layer (Terraform)](#infrastructure-layer-terraform)
* [Application Layer (Kubernetes)](#application-layer-kubernetes)
* [Future Enhancements & Ideas](#future-enhancements--ideas)

---

## 🧱 Infrastructure Layer (Terraform)

A dedicated **Terraform** repository provisions the foundational AWS infrastructure, including:

* ✅ Amazon EKS Cluster
* ✅ Managed Node Groups
* ✅ IAM Roles and Policies
* ✅ **Scheduled Node Autoscaling**:

  * Scales node group **down to zero** at **midnight (00:00)**.
  * Scales **back up** at **noon (12:00)**.
  * Saves costs during low-usage hours while maintaining availability when needed.

All infrastructure provisioning and updates are triggered through a **CI/CD pipeline**, enabling Git-based infrastructure-as-code delivery.

---

## 📦 Application Layer (Kubernetes)

A separate GitHub Actions pipeline deploys Kubernetes application resources:

* **Namespace**: `faiyaz-gitops`
* **Pods & Deployments**
* **Service Accounts**
* **LoadBalancer Service**
* **Horizontal Pod Autoscaler (HPA)**:

  * Dynamically scales pods based on CPU utilization.
  * Example: Scale from 1–5 replicas if CPU usage exceeds 60%.

All Kubernetes manifests are versioned in Git and applied to the cluster using `kubectl` through GitHub Actions.

---

## 🔭 Future Enhancements & Ideas

To improve the platform’s scalability, security, and observability:

### 🔄 GitOps Tools Integration

* Integrate **ArgoCD** or **FluxCD** for declarative, Git-synced Kubernetes deployments.

### 📦 Helm Charts

* Replace raw YAML manifests with **Helm** to templatize Kubernetes resources and manage versioned releases.

### 🌍 Multi-Environment Support

* Add support for **dev / staging / prod** using:

  * Terraform workspaces or directory structure
  * Separate GitHub Actions workflows

### 🔐 Secrets Management

* Manage sensitive configs securely using:

  * **AWS Secrets Manager**
  * **Sealed Secrets**
  * **HashiCorp Vault**

### 📈 Observability Stack

* Deploy a monitoring and logging stack:

  * **Prometheus + Grafana** for metrics
  * **CloudWatch Logs** integration

### 🔒 Security & Compliance

* Enforce security policies using:

  * **OPA Gatekeeper** or **Kyverno**
  * Integrate scanning tools like **Checkov**, **Trivy**, or **Kube-bench**
