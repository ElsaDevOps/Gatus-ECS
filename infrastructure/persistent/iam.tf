resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_iam_role" "gitrole" {
  name               = "git-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  lifecycle {
    prevent_destroy = true
  }
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
      values   = ["repo:ElsaDevOps/Gatus-ECS:ref:refs/heads/main", "repo:ElsaDevOps/Gatus-ECS:pull_request", "repo:ElsaDevOps/Gatus-ECS:environment:production"]
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
    sid    = "EC2Permissions"
    effect = "Allow"
    actions = ["ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DescribeVpcs",
      "ec2:ModifyVpcAttribute",
      "ec2:DescribeVpcAttribute",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroupRules",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:DescribeInternetGateways",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:DeleteNatGateway",
      "ec2:DescribeNatGateways",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      "ec2:DescribeAddresses",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:DescribeRouteTables",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DescribeRegions",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:ModifySubnetAttribute",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddressesAttribute",
    "ec2:DescribeNetworkAcls"]
    resources = ["*"]
  }

  statement {
    sid    = "ECSPermissions"
    effect = "Allow"
    actions = ["ecs:CreateCluster",
      "ecs:DeleteCluster",
      "ecs:DescribeClusters",
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
    "ecs:ListTasks"]
    resources = ["*"]
  }

  statement {
    sid    = "ELBPermissions"
    effect = "Allow"
    actions = ["elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerAttributes",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:RemoveTags",
    "elasticloadbalancing:DescribeTags"]
    resources = ["*"]
  }

  statement {
    sid    = "Route53Permissions"
    effect = "Allow"
    actions = ["route53:ChangeResourceRecordSets",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",

    ]
    resources = ["arn:aws:route53:::hostedzone/${data.aws_route53_zone.main.zone_id}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    sid    = "WAFPermissions"
    effect = "Allow"
    actions = ["wafv2:CreateWebACL",
      "wafv2:DeleteWebACL",
      "wafv2:GetWebACL",
      "wafv2:UpdateWebACL",
      "wafv2:ListWebACLs",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:ListTagsForResource",
      "wafv2:TagResource",
    "wafv2:UntagResource"]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchPermissions"
    effect = "Allow"
    actions = ["cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:TagResource",
    "cloudwatch:UntagResource"]
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
