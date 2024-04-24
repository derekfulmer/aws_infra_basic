locals {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCEKddyAlRoJOyow+JGDuoyvDAnTf8kKEvkkrTwZVQNH31FULiGgBy1q7brWBik7HTyqLXcc1bySkxU7fEzmCkaxPYBRFsLwUuLZVPLAZPwCPDqDnADyVDZWnvpsI1xrDFzSZx9pRZYB9NKznj3sMe7Bnzyay8FCPP4yFWmdmA4hS6Yu05yoSPYNU5GVXVR+ysieUWB9nIO9KFqJecnVcHlO3WcMIYa0fVba7A9qB+0VHkAepoMHf5HL3gEciAXAi5FfflMC2nbiWKwiXGZPrqapQciwy4ZlWQL435erU0qzseFb0LEOVx6sxuoxnnKGbMpqd4OKI9gVSIRyOwsGxA9"
}

resource "aws_key_pair" "ops" {
  key_name   = "${var.stack_name}-ops"
  public_key = local.public_key
}

#########
# EC2 for gates
########
resource "aws_instance" "host" {
  subnet_id     = var.subnet_id_list[0]
  ami = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.ztgate_host_sg.id]
  iam_instance_profile = aws_iam_instance_profile.iam_profile_ztgate_host.name
  user_data = "${file("ztgate_userdata.sh")}"
  key_name = aws_key_pair.ops.key_name
  root_block_device {
    encrypted   = true
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  lifecycle {
    ignore_changes = [ami, instance_type]
  }

  tags = {
    Name = "ztgate"
    ztgate = true
  }

  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

}



