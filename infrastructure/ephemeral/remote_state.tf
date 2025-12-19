data "terraform_remote_state" "persistent" {
  backend = "s3"
  config = {
    bucket = "terraform-state-gatus-elsa"
    key    = "gatus/persistent/terraform.tfstate"
    region = "eu-west-2"
  }
}
