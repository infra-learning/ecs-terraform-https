terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.60" }
  }
}

provider "aws" {
  region  = var.region
  profile = "iac_learning"
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}
