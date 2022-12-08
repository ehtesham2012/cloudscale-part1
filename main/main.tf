terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.0"
    }
  }
}

# configure the AWS provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags= {
        Application = "Static_Website"
        Owner = "eht444"
    }
  }
}

#Creating the website module
module "staticWebsite" {
    source = "./../staticWebsite"
    bucketname = "cloudscale-part1-static-bucket"
    domain_name = "cloudscale-part1-static-bucket.s3.amazonaws.com"
}