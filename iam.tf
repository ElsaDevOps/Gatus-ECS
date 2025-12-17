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


resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.gitrole.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
