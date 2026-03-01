# =============================================================================
# Database Infrastructure - Main Configuration
# Provisions RDS PostgreSQL managed database
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "auto-repair-shop-terraform-state"
    region         = "us-east-2"
    dynamodb_table = "auto-repair-shop-terraform-locks"
    encrypt        = true
    # key is passed dynamically via -backend-config in CI/CD:
    # staging:    key = "database-infrastructure/staging/terraform.tfstate"
    # production: key = "database-infrastructure/production/terraform.tfstate"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  resource_suffix = random_id.suffix.hex
}

# -----------------------------------------------------------------------------
# Remote State: Read k8s-infrastructure outputs for VPC / subnet / SG info
# -----------------------------------------------------------------------------

data "terraform_remote_state" "k8s_infra" {
  backend = "s3"

  config = {
    bucket = "auto-repair-shop-terraform-state"
    key    = "fiap-13soat-auto-repair-shop-k8s-${var.environment}/terraform.tfstate"
    region = "us-east-2"
  }
}

# -----------------------------------------------------------------------------
# Database Module
# -----------------------------------------------------------------------------

module "database" {
  source = "./modules/database"

  project_name    = var.project_name
  environment     = var.environment
  resource_suffix = local.resource_suffix

  # Networking from k8s-infrastructure
  vpc_id             = data.terraform_remote_state.k8s_infra.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.k8s_infra.outputs.private_subnet_ids

  # Database configuration
  db_instance_class       = var.db_instance_class
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_allocated_storage    = var.db_allocated_storage
  db_max_allocated_storage = var.db_max_allocated_storage
  db_backup_retention_period = var.db_backup_retention_period

  # Allow access from EKS nodes (pass private subnet CIDRs for CIDR-based rules)
  private_subnet_cidrs = var.private_subnet_cidrs
}
