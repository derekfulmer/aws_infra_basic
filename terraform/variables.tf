
variable "region" {
  description = "Target Region for this deployment"
  type        = string
}

variable "default_tags" {
  type = map(string)
  default = {
    "terraform_deploy" = "true"
  }
}

variable "vpc_cidr" {
  type = string
  default = "10.1.0.0/16"
}


variable "tags" {
  description = "A mapping of tags to assign to each resource"
  default     = {}
}

variable "stack_name" {
  description = "Stack name passed in from script"
  type        = string
}

variable "environment" {
  description = "environment name based on account"
  type        = string
}

variable "instance_type" {
  type = string
  default = "m5.large"
}

