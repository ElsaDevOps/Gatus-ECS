

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.1"
    }


  }
}

provider "aws" {
  region = "eu-west-2"
}
