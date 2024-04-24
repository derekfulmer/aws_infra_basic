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

variable "aws_account_id" {
  description = "ID number of the current account. "
}

