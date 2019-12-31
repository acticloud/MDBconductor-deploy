# This Terraform setup can be configured by setting a number of variables. This
# file defines the variables, a separate file `terraform.tfvars` contains their
# actual values.
#
# Copy 'terraform.tfvars.example' to 'terraform.tfvars' and DO NOT check that
# file into version control. It is local to your experiment.

# Name of this cluster. Used in the network configurations. Will also be visible
# in the AWS console so you can see which machines belong to this cluster.
variable cluster_name {}

# region in which to create the VM's
variable aws_region {
  default = "eu-central-1"
}

variable conductor_instance_type {
  default = "t2.micro"
}

variable nr_of_small_minions {
  default = 1
}

variable small_minion_instance_type {
  default = "t2.micro"
}

variable nr_of_large_minions {
  default = 1
}

variable large_minion_instance_type {
  default = "t2.small"
}

# Name of the SSH key you will use to connect to the virtual machines.
# This is not the file name but the name by which it is known to AWS.
# See https://docs.aws.amazon.com/en_pv/AWSEC2/latest/UserGuide/ec2-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws
variable ssh_key {}

# AMI to use.
# You can use the AWS command line utility to query for a recent image
# as follows:
# $ aws ec2 describe-images
#       --owners 099720109477  \
#       --filters  \
#            "Name=virtualization-type,Values=hvm"  \
#            "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*" \
#       --query 'sort_by(Images, &CreationDate)[-1].{name:Name,id:ImageId}'
variable ami_id {
  # Unfortunately we're not allowed to have variables
  # in the default
  #default = data.aws_ami.ubuntu_ami.id
}