
#######################################
# SEC GROUP
#######################################
resource "aws_security_group" "host_sg" {
  name = "host-sg"
  description = "AWS security group for a host"
  vpc_id = var.vpc_id
  revoke_rules_on_delete = true
  tags = {
    Name = "host_sg"
  }
}


#######################################
# SEC GROUP RULES
#######################################
# Host Rules
resource "aws_security_group_rule" "ssh_inbound" {
  security_group_id =  aws_security_group.host_sg.id
  description = "Allow SSH inbound"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [var.cidr]
}

resource "aws_security_group_rule" "host_all_outbound" {
  security_group_id =  aws_security_group.ztgate_host_sg.id
  description = "Allow All Outbound"
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

