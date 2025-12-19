resource "aws_ecr_repository" "my_gatus" {
  name                 = "my-gatus"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
