resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]


}

resource "aws_iam_role" "gitrole" {
  name               = "git-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]


    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:ElsaDevOps/Gatus-ECS:ref:refs/heads/main", "repo:ElsaDevOps/Gatus-ECS:pull_request"]
    }
  }


}

data "aws_iam_policy_document" "github_actions_permissions" {
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
    "ecr:GetAuthorizationToken"]
    resources = ["*"]

  }

  statement {
    sid    = "ECRPush"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
    "ecr:CompleteLayerUpload"]
    resources = [aws_ecr_repository.my_gatus.arn]

  }

  statement {
    sid    = "TerraformState"
    effect = "Allow"
    actions = [

      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::terraform-state-gatus-elsa",


    ]

  }

  statement {
    sid    = "S3ReadPersistentState"
    effect = "Allow"
    actions = [

      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::terraform-state-gatus-elsa/persistent/*",
    ]

  }

  statement {
    sid    = "S3ReadWriteEphemeralState"
    effect = "Allow"
    actions = [

      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::terraform-state-gatus-elsa/ephemeral/*",
    ]

  }
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.gitrole.name
  policy_arn = data.aws_iam_policy_document.github_actions.arn
}

resource "aws_iam_policy" "github_actions" {
  name   = "github-actions-role"
  policy = data.aws_iam_policy_document.github_actions_trust.json
}

resource "aws_iam_policy" "github_actions" {
  name   = "github-actions-permissions"
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}
