provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.7"
    }
  }

  backend "remote" {
    organization = "4amlunch-home"

    workspaces {
      name = "chremoas_aws_cluster"
    }
  }
}

