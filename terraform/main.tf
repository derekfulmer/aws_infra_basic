module "network" {
  source           = "./modules/standard-network"
  cidr             = var.vpc_cidr
  environment      = var.environment
  region           = var.region
  stack_name       = var.stack_name
  aws_account_id   = local.aws_account_id
}


module "ec2" {
  source           = "./modules/ec2"
  vpc_id           = module.network.vpc_id
  stack_name       = var.stack_name
  ami_id           = data.aws_ami.ubuntu.id
  instance_type    = var.instance_type
  aws_account_id   = local.aws_account_id
  depends_on       = [ module.network ]
  subnet_id_list   = module.network.public_subnet_list
  environment      = var.environment
  region           = var.region
}


