# 🚀 AWS EKS Infrastructure with Terraform (VPC · EKS · RDS)

Production-style Infrastructure-as-Code project that provisions a complete, secure AWS foundation for a containerized e-commerce workload — a custom VPC, an Amazon EKS cluster with a managed node group, and a MySQL RDS backend — fully automated with **Terraform**.

![Terraform](https://img.shields.io/badge/Terraform-6.61.0-844FBA?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20VPC%20%7C%20RDS-FF9900?logo=amazonaws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.35-326CE5?logo=kubernetes&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## 📖 Overview

This repository defines the AWS infrastructure layer for the **ShopSphere** e-commerce platform. It builds a two-tier network (public + private subnets across 2 AZs), deploys an Amazon EKS cluster into the private subnets for the application workloads, and provisions a private RDS MySQL instance for persistent storage — all wired together with least-exposure security groups and IAM roles scoped to AWS-managed policies.

**Region:** `ap-south-1` (Mumbai)

---

## 🏗️ Architecture

```
                                   ┌─────────────────────────────┐
                                   │        Internet Gateway     │
                                   └──────────────┬───────────────┘
                                                  │
                        ┌─────────────────────────┴─────────────────────────┐
                        │                       VPC (10.0.0.0/16)            │
                        │                                                     │
        ┌───────────────┴───────────────┐               ┌────────────────────┴──────────────┐
        │   Public Subnet 1 (AZ-a)       │               │    Public Subnet 2 (AZ-b)          │
        │   10.0.1.0/24                  │               │    10.0.2.0/24                     │
        │   NAT Gateway + EIP            │               │                                    │
        └───────────────┬───────────────┘               └────────────────────┬──────────────┘
                        │                                                     │
                        └─────────────────────────┬─────────────────────────┘
                                                  │  (Private Route Table → NAT)
                        ┌─────────────────────────┴─────────────────────────┐
                        │                                                     │
        ┌───────────────┴───────────────┐               ┌────────────────────┴──────────────┐
        │  Private Subnet 1 (AZ-a)       │               │   Private Subnet 2 (AZ-b)          │
        │  10.0.3.0/24                   │               │   10.0.4.0/24                      │
        │                                 │               │                                    │
        │   ┌─────────────────────────────────────────────────────────────┐                   │
        │   │              Amazon EKS Cluster (v1.35)                     │                   │
        │   │              devops-node-group (t2.large, 1–3 nodes)        │                   │
        │   └─────────────────────────────────────────────────────────────┘                   │
        │                                 │               │                                    │
        │   ┌─────────────────────────┐   │               │  ┌─────────────────────────┐       │
        │   │  RDS MySQL 8.0          │◄──┴───────────────┴──┤  (DB Subnet Group)       │       │
        │   │  db.t3.micro            │                      │                          │       │
        │   └─────────────────────────┘                      └─────────────────────────┘       │
        └───────────────────────────────┘               └────────────────────────────────┘
```

---

## 📁 Repository Structure

```
terraform/
├── provider.tf         # AWS provider & Terraform version constraints
├── variables.tf        # Input variable declarations
├── terraform.tfvars     # Variable values (region, CIDRs, credentials)
├── vpc.tf              # VPC, subnets, IGW, NAT gateway, route tables
├── securitygroup.tf     # Dynamic ingress/egress security group for EKS
├── iam.tf              # IAM roles & policy attachments for EKS cluster/nodes
├── eks.tf              # EKS cluster + managed node group
├── rds.tf              # RDS security group, subnet group & MySQL instance
└── outputs.tf          # Exported resource identifiers & endpoints
```

---

## 🧩 Components

| File | Resource(s) | Purpose |
|---|---|---|
| `provider.tf` | `aws` provider (v6.61.0) | Pins the AWS provider version and target region |
| `vpc.tf` | VPC, 2 public + 2 private subnets, IGW, NAT Gateway, route tables | Two-tier network spanning 2 Availability Zones |
| `securitygroup.tf` | `aws_security_group.eks_cluster_sg` | Dynamic ingress rules (22, 80, 8080, 3306) for the EKS/web tier |
| `iam.tf` | EKS cluster role, EKS node role + managed policy attachments | Least-privilege roles for the control plane and worker nodes |
| `eks.tf` | `aws_eks_cluster`, `aws_eks_node_group` | EKS v1.35 control plane + `t2.large` managed node group (1–3 nodes, autoscaling) |
| `rds.tf` | `aws_security_group.rds-sg`, `aws_db_subnet_group`, `aws_db_instance` | Private MySQL 8.0 instance (`db.t3.micro`) reachable only from EKS nodes on port 3306 |
| `outputs.tf` | Output values | Surfaces VPC, subnet, EKS, and RDS identifiers after apply |

---

## ⚙️ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.5`
- AWS account with credentials configured (`aws configure` or environment variables)
- IAM permissions to create VPC, EKS, IAM, and RDS resources
- `kubectl` (to interact with the cluster post-deployment)
- `aws-iam-authenticator` or AWS CLI v2 (for EKS auth)

---

## 🔑 Input Variables

| Variable | Type | Description |
|---|---|---|
| `aws_region` | `string` | AWS region to deploy into |
| `vpc-cidr` | `string` | CIDR block for the VPC |
| `cidr-block` | `list(string)` | CIDR blocks for the 6 subnets (2 public, 2 private-app, 2 private-DB) |
| `az` | `list(string)` | Availability zones used for subnet placement |
| `rtb-cidr` | `string` | Destination CIDR for route table default routes |
| `eip-domain` | `string` | Domain type for the NAT Gateway's Elastic IP |
| `sg-name` | `string` | Name of the EKS/web security group |
| `for-each` | `list(number)` | Ports opened on the security group via `dynamic` block |
| `protocol` | `string` | Protocol for ingress rules |
| `ipv4-cidr` / `ipv6-cidr` | `list(string)` | Allowed CIDRs for ingress/egress |
| `egress-protocol` | `string` | Egress protocol (`-1` = all) |
| `cluster_name` | `string` | Name of the EKS cluster |
| `eks_cluster_role` / `eks_node_role` | `string` | IAM role names for the EKS control plane and nodes |
| `db_name` / `db_username` / `db_password` | `string` | RDS MySQL database credentials |

> Default values for this environment live in `terraform.tfvars` (region: `ap-south-1`, cluster: `ecommerce-dev-eks`).

---

## 🚀 Usage

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>/terraform

# 2. Initialize Terraform
terraform init

# 3. Review the execution plan
terraform plan

# 4. Apply the configuration
terraform apply

# 5. Configure kubectl to talk to the new cluster
aws eks update-kubeconfig --region ap-south-1 --name ecommerce-dev-eks

# 6. Verify node group is ready
kubectl get nodes
```

### Destroy

```bash
terraform destroy
```

---

## 📤 Outputs

| Output | Description |
|---|---|
| `vpc_id`, `internet_gateway_id` | Core networking identifiers |
| `web_public_subnet_1_id`, `web_public_subnet_2_id` | Public subnet IDs |
| `app_private_subnet_1_id`, `app_private_subnet_2_id` | Private subnet IDs |
| `public_route_table_id`, `private_route_table_id`, `nat_gateway_id` | Routing resources |
| `web_security_group_id` | EKS/web security group ID |
| `cluster_name`, `cluster_endpoint`, `cluster_arn`, `node_group_name` | EKS cluster details |
| `rds_endpoint`, `rds_port`, `rds_database_name` | RDS connection details |

---

## 🔒 Security Notes

- **Do not commit real secrets.** `terraform.tfvars` in this project currently contains a plaintext `db_password`. Before pushing to GitHub:
  - Add `terraform.tfvars` and `*.tfstate*` to `.gitignore`.
  - Commit a sanitized `terraform.tfvars.example` with placeholder values instead.
  - For real deployments, source `db_password` from **AWS Secrets Manager** or mark the variable `sensitive = true` and pass it via `TF_VAR_db_password` / a CI/CD secret store.
- The RDS security group and DB subnet group restrict MySQL access to the private application subnets only — the database is never publicly reachable.
- The EKS node group runs in private subnets; only the cluster API endpoint is publicly accessible (`endpoint_public_access = true`), with private access also enabled for in-VPC traffic.
- IAM roles are scoped to AWS-managed policies (`AmazonEKSClusterPolicy`, `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`) — no wildcard permissions.

Suggested `.gitignore`:
```
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfvars
crash.log
```

---

## 🗺️ Roadmap

- [ ] Migrate state to a remote S3 backend with DynamoDB locking
- [ ] Add Terraform modules for VPC / EKS / RDS reusability
- [ ] Integrate with GitHub Actions for `plan`/`apply` CI/CD
- [ ] Layer on Helm charts + ArgoCD for GitOps deployment of ShopSphere
- [ ] Add Prometheus/Grafana monitoring stack via Terraform/Helm

---

## 👤 Author

**Akhilesh** — AWS Cloud & DevOps Engineer  
Building a production-style DevOps portfolio (Terraform → EKS → Helm → ArgoCD → Prometheus/Grafana → GitHub Actions CI/CD).

---

## 📄 License

This project is licensed under the MIT License.
