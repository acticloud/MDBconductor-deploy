# Networking

# A security group is a list of firewall rules.
# VM's can declare that they are part of a security group and then
# those rules are applied to their communication.
# VM's that do not declare security group get a default one from Amazon.
resource aws_security_group firewall {
  name        = "${var.cluster_name}_firewall"
  description = "Firewall rules for cluster ${var.cluster_name}"
}

# Communication between security group members is unrestricted.
resource aws_security_group_rule internal {
  description       = "internal communication"
  type              = "ingress"
  security_group_id = aws_security_group.firewall.id
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

# Outgoing communication is also unrestricted.
resource aws_security_group_rule egress {
  description       = "internal communication"
  type              = "egress"
  security_group_id = aws_security_group.firewall.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Incoming SSH is ok.
resource aws_security_group_rule ssh {
  description       = "incoming ssh"
  type              = "ingress"
  security_group_id = aws_security_group.firewall.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}
