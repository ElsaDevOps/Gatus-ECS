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
  #checkov:skip=CKV_AWS_356:Broad permissions required for Terraform provisioning - will tighten using CloudTrail audit post-deployment
  #checkov:skip=CKV_AWS_107:ECR GetAuthorizationToken requires wildcard resource - AWS limitation
  #checkov:skip=CKV_AWS_109:IAM permissions scoped to specific execution role only
  #checkov:skip=CKV_AWS_111:Write permissions required for infrastructure creation - will tighten post-deployment

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
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages"
    ]
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
      "arn:aws:s3:::terraform-state-gatus-elsa/gatus/persistent/*",
    ]

  }

  statement {
    sid    = "S3ReadWriteEphemeralState"
    effect = "Allow"
    actions = [

      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::terraform-state-gatus-elsa/gatus/ephemeral/*",
    ]

  }


  statement {
    sid    = "IAMTaskExecutionRole"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:TagRole",
      "iam:PassRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListInstanceProfilesForRole"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Execute-role"
    ]
  }

  statement {
    sid       = "EC2Permissions"
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }

  statement {
    sid       = "ECSPermissions"
    effect    = "Allow"
    actions   = ["ecs:*"]
    resources = ["*"]
  }

  statement {
    sid       = "ELBPermissions"
    effect    = "Allow"
    actions   = ["elasticloadbalancing:*"]
    resources = ["*"]
  }

  statement {
    sid       = "Route53Permissions"
    effect    = "Allow"
    actions   = ["route53:*"]
    resources = ["*"]
  }

}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.gitrole.name
  policy_arn = aws_iam_policy.github_actions.arn
}



resource "aws_iam_policy" "github_actions" {
  name   = "github-actions-permissions"
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}

data "aws_caller_identity" "current" {}
