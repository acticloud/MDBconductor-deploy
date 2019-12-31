# # Machine definitions

resource aws_instance conductor {
  ami             = var.ami_id
  instance_type   = var.conductor_instance_type
  key_name        = var.ssh_key
  security_groups = [aws_security_group.firewall.name]
  iam_instance_profile = aws_iam_instance_profile.conductor_profile.name
  tags = {
    Name           = "${var.cluster_name}_conductor",
    cluster        = var.cluster_name,
    cluster_groups = "conductor",
  }
}

resource aws_instance small_minion {
  count           = var.nr_of_small_minions
  ami             = var.ami_id
  instance_type   = var.small_minion_instance_type
  key_name        = var.ssh_key
  security_groups = [aws_security_group.firewall.name]
  tags = {
    Name           = "${var.cluster_name}_small${count.index + 1}",
    cluster        = var.cluster_name,
    cluster_groups = "minions",
    size           = "small",
  }
}


resource aws_instance large_minion {
  count           = var.nr_of_large_minions
  ami             = var.ami_id
  instance_type   = var.large_minion_instance_type
  key_name        = var.ssh_key
  security_groups = [aws_security_group.firewall.name]
  tags = {
    Name           = "${var.cluster_name}_large${count.index + 1}",
    cluster        = var.cluster_name,
    cluster_groups = "minions",
    size           = "large",
  }
}
