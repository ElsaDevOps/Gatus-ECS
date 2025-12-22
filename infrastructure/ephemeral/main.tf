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
  certificate_arn      = data.terraform_remote_state.persistent.outputs.certificate_arn
  alt_domain           = local.alt_domain

}

module "security" {
  source = "../modules/security"

  vpc_id = module.vpc.vpc_id
}

module "ecs" {
  source = "../modules/ecs"

  ecr_url               = data.terraform_remote_state.persistent.outputs.ecr_repository_url
  subnet_ids            = values(module.vpc.private_subnet_id_app)
  ecs_security_group_id = module.security.gs_app_sg_id
  image_tag             = var.image_tag
  target_group_arn      = module.loadbalancer.target_group_arn
}
