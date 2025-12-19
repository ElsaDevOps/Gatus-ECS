module "vpc" {
  source = "../modules/vpc"

  cidr_blockvpc           = local.network_config.cidr_vpc
  cidr_public_subnet_web  = local.network_config.cidr_public_subnet_web
  cidr_private_subnet_app = local.network_config.cidr_private_subnet_app
  availability_zones      = local.network_config.availability_zones
  project_name            = var.project_name
}

module "loadbalancer" {
  source               = "../modules/loadbalancer"
  gs_alb_sg_id         = module.security.gs_alb_sg_id
  vpc_id               = module.vpc.vpc_id
  public_subnet_id_web = module.vpc.public_subnet_id_web
  domain_name          = var.domain_name
  certificate_arn      = var.certificate_arn
}

module "security" {
  source = "../modules/security"

  vpc_id = module.vpc.vpc_id
}
