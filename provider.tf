terraform {
  required_version = ">=1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.primary_region
}

# provider "aws" {
#   alias  = "awsalternate"
#   region = var.secondary_region
# }