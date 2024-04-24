# do-tf-ztgate-infra

Creates AWS infrastucture networking required to route traffic in and out of the VPC.

This repository contains code that performs the following actions:
    - Creates an AWS VPC and configures networking
    - Creates an AWS EC2 instance to serve as an exit gate

This `run.sh` script wraps terraform code in shell code and requires input variables in order to be run successfully:  
    - `ACTION`: A `Terraform` action to `plan`, `apply`, or `destroy` resources.  
    - `ACCOUNT`: The AWS account in which to create resources; e.g. Dev, QA, etc 
    - `AWS_REGION`: Which AWS region to deploy into. This affects networking.  
    - `STACK_NAME`: A unique label, or identifier, for the resources. This not only helps keep track of what has been deployed and where, but it serves as a means of separating resoruces in Terraform's remote state in AWS S3.  
