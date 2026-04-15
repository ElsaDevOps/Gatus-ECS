

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.40.0"
    }


  }
}

provider "aws" {
  region = "eu-west-2"
}
