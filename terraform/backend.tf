terraform {
  required_version = "~> 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.27"
    }
  }

  backend "s3" {
    bucket         = "020056064827-terraform-state"
    key            = "eks-gitops-platform/dev/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "eks-gitops-platform-dev-terraform-lock"
    encrypt        = true
  }
}

