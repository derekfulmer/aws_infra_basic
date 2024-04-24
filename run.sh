#!/usr/bin/env bash

# This script only works with environment variables because it is assumed that it is begin run from a Jenkins pipeline.

if [ -z "$ACTION" ] || [ -z "$ACCOUNT" ] || [ -z "$AWS_REGION" ] || [ -z "$STACK_NAME" ];
then
    echo "Set the following environment variables before running:"
    echo "1. ACTION"
    echo "2. ACCOUNT"
    echo "3. AWS_REGION"
    echo "4. STACK_NAME"
    exit 1
fi

if ! [[ ["plan","apply","destroy"] =~ "$ACTION" ]]; then
    echo "ACTION must be one of [plan, apply, destroy]"
    exit 1
fi

echo @@@@@ Creating VPC with following values
echo ACCOUNT = "$ACCOUNT"
echo REGION = "$AWS_REGION"
echo NAME = "$STACK_NAME"

echo @@@@@ CD to terraform
echo cd terraform
cd terraform || exit
pwd

echo @@@@@ Cleanup previous account specific files
echo rm -rf init.tf vars.tfvars tfplan* init.tf vars.tfvars *.tfstate
rm -rf init.tf vars.tfvars tfplan* init.tf vars.tfvars *.tfstate

echo @@@@@ Add TF Init
echo """terraform {
  backend \"s3\" {
    bucket = \"deploy-${ACCOUNT}-tfstate\"
    key    = \"terraform-deploy\"
    region = \"us-east-2\"
    dynamodb_table = \"terraform-lock\"
  }
}
""" > init.tf
cat init.tf

echo @@@@@ Add TF Vars
echo "environment = \"$ACCOUNT\"" >> vars.tfvars
echo "region = \"us-east-2\"" >> vars.tfvars
echo "stack_name = \"$STACK_NAME\"" >> vars.tfvars
cat vars.tfvars


echo @@@@@ terraform init
terraform init -no-color

echo @@@@ Checking for workspace name
NAMECHECK=$(terraform workspace list | grep $STACK_NAME | wc -l)
if [ "$NAMECHECK" -gt 0 ]; then
    echo The workspace labeled "$STACK_NAME" already exists.  Selecting existing workspace
    terraform workspace select "$STACK_NAME" -no-color
else
    terraform workspace new "$STACK_NAME" -no-color
    terraform workspace select "$STACK_NAME" -no-color
fi

echo @@@@ Workspace creation good to go.
terraform workspace list -no-color

echo Running terraform init
terraform init

if [[ "$ACTION" == "plan" ]]; then
    echo Running Terraform plan
    terraform plan -var-file="vars.tfvars" -no-color -out tfplan
    terraform show -json tfplan | jq > tfplan.json
    exit 0
fi

if [[ "$ACTION" == "apply" ]]; then
    echo Running Terraform apply
    terraform apply -var-file="vars.tfvars" -auto-approve -no-color
    if [ $? -ne 0 ]; then
        echo The workspace labeled $STACK_NAME failed to finish the terraform apply step.
        exit 1
    fi
    # Sleep for 3 min to allow EC2s complete
    sleep 180
    echo "Done Deploying $ACCOUNT $STACK_NAME"
    exit 0
fi

if [[ "$ACTION" == "destroy" ]]; then
    echo @@@@@ Running Terraform destroy
    terraform destroy -var-file="vars.tfvars" -auto-approve -no-color

    echo @@@@@ Sleeping for 60
    sleep 60

    echo @@@@@ Running Terraform destroy 2nd time.  This 2nd run can be addressed in future version.
    terraform destroy -var-file="vars.tfvars" -auto-approve -no-color

    echo @@@@@ Removing workspace
    terraform workspace select default -no-color
    terraform workspace delete "$STACK_NAME" -no-color
    terraform workspace list -no-color
    # Sleep for 3 min to allow EC2s to complete
    sleep 180

    echo "Done "
    exit 0
fi
