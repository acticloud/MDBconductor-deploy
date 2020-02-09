# Load the aws-plugin for terraform.
provider aws {
  version = "~> 2.0"
  region  = var.aws_region
}

# AWS Account id number, for example 333323848586
data "aws_caller_identity" "current" {}

output aws_region {
  value = var.aws_region
}