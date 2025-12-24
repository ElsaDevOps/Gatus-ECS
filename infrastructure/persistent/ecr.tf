resource "aws_ecr_repository" "my_gatus" {
  #checkov:skip=CKV_AWS_136:Non-production environment, default AES-256 encryption sufficient
  name                 = "my-gatus"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
