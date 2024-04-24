variable "cidr" {
  description = "The CIDR to assign to the VPC and used for subnet creation"
  default = "10.1.0.0/16"
  type = string
}

variable "stack_name" {
  description = "The name associated with this environment e.g. prod01, prod02, qa02"
  type = string
}

variable "region" {
  description = "Region name e.g. us-east-2"
  type = string
}

variable "environment" {
  description = "prod/stage/qa"
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
  default = "m5.large"
}

variable "volume_type" {
  description = "The type of block device to create and/or attach to the instance"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "The size of the volume to attach"
  type        = number
  default     = 100
}

variable "subnet_id_list" {
  type = list(string)
}

variable "aws_account_id" {
  description = "The current account's ID"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "ec2_name" {
  type = list(string)
  default = ["none"]
}


