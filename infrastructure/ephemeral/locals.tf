locals {
  network_config = {
    cidr_vpc                = var.cidr_blockvpc
    cidr_public_subnet_web  = var.cidr_public_subnet_web
    cidr_private_subnet_app = var.cidr_private_subnet_app
    availability_zones      = var.availability_zones
  }

  alt_domain = "tm.${var.domain_name}"
}
