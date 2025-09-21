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

variable "domain_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}
