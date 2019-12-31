# Load the aws-plugin for terraform.
provider aws {
  version = "~> 2.0"
  region  = var.aws_region
}
