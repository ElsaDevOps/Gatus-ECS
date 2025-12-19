terraform {
  backend "s3" {
    bucket       = "terraform-state-gatus-elsa"
    key          = "gatus/ephemeral/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
