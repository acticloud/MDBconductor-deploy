

# Role which the conductor will use to start/stop its minions.
resource aws_iam_role conductor_role {
  name_prefix        = "conductor_role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}


# Allow the conductor_role to start/stop the minions.
resource aws_iam_role_policy allow_conductor_startstop {
  name_prefix = "allow_${var.cluster_name}_${var.aws_region}_conductor_startstop"
  role        = aws_iam_role.conductor_role.id
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstanceStatus"
      ],
      "Resource": "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "Condition": {
        "StringEquals":{
          "ec2:ResourceTag/cluster":"${var.cluster_name}",
          "ec2:ResourceTag/cluster_groups":"minions"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
EOF
}

# For some reason we have to wrap the role in a profile
# before we can assign it to our master node
resource aws_iam_instance_profile conductor_profile {
  name_prefix = "conductor_profile"
  role        = aws_iam_role.conductor_role.name
}


# Only for readability. Every EC2 role needs this "assume policy"
# which specifies who is allowed to assume the role. It's identical
# between all instances and it's ugly to put it inline. 
# See https://www.terraform.io/docs/providers/aws/r/iam_role.html
data aws_iam_policy_document instance-assume-role-policy {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
