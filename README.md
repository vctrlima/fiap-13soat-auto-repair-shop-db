# Database Infrastructure

Terraform module for provisioning the PostgreSQL database on AWS RDS.

## What This Provisions

- **RDS PostgreSQL 16** instance with encryption at rest
- **DB Subnet Group** in private subnets (from k8s-infrastructure VPC)
- **Security Group** allowing access from EKS nodes and Lambda
- **Enhanced Monitoring** IAM role
- **Performance Insights** and CloudWatch log exports
- **Versioned SQL migrations**

## Module Structure

```
database-infrastructure/
├── terraform/
│   ├── main.tf                # Root module + remote state reference
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Exported values
│   ├── modules/
│   │   └── database/          # RDS instance, SG, subnet group
│   └── environments/
│       ├── staging/
│       │   └── terraform.tfvars
│       └── production/
│           └── terraform.tfvars
└── migrations/
    └── V1__initial_schema.sql # Initial schema from Prisma
```

## Cross-Stack Dependencies

This module reads VPC and subnet IDs from the k8s-infrastructure Terraform state via `terraform_remote_state`:

```hcl
data "terraform_remote_state" "k8s_infra" {
  backend = "s3"
  config = {
    bucket = "auto-repair-shop-terraform-state"
    key    = "k8s-infrastructure/terraform.tfstate"
    region = "us-east-2"
  }
}
```

**Deploy k8s-infrastructure first.**

## Usage

```bash
cd database-infrastructure/terraform

# Initialize
terraform init

# Plan
terraform plan -var-file=environments/production/terraform.tfvars

# Apply
terraform apply -var-file=environments/production/terraform.tfvars
```

## Key Outputs

| Output                       | Description               |
| ---------------------------- | ------------------------- |
| `database_host`              | RDS endpoint hostname     |
| `database_port`              | Port (5432)               |
| `database_name`              | Database name             |
| `database_endpoint`          | Full `host:port` endpoint |
| `database_security_group_id` | SG ID for ingress rules   |

## Environment Configurations

| Parameter        | Staging     | Production   |
| ---------------- | ----------- | ------------ |
| Instance class   | db.t3.small | db.t3.medium |
| Storage (GB)     | 10          | 20           |
| Max storage (GB) | 20          | 50           |
| Backup retention | 3 days      | 7 days       |
| Multi-AZ         | No          | No           |

## Deployment

Deployed via GitHub Actions (`.github/workflows/cd.yml`) with manual approval gate for the `production` environment.
