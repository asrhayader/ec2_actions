locals {
  prefix            = "TF-"  #Prefix for Roles & Policies
  oidc_provider_arn = "arn:aws:iam::${var.aws_account}:oidc-provider/token.actions.githubusercontent.com" 
  region = var.aws_region
  resource = "ec2"
  github_organization = "asrhayader"
  github_repo = "ec2_actions"

  #Statements map to generate policy
  statements =  [{ 
    effect    = "Allow"
    actions   = ["ec2:DescribeInstances","ec2:StopInstances","ec2:StartInstances"]
#    actions   = ["ec2:DescribeInstances","ec2:StopInstances","ec2:StartInstances","route53:ListResourceRecordSets","route53:ChangeResourceRecordSets"]
    resources = ["*"]
    }
  ]
}

#Github OIDC connection provider
data "aws_iam_openid_connect_provider" "github" {
  arn = local.oidc_provider_arn
}

#Policy document for github integration
data "aws_iam_policy_document" "github_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_organization}/${local.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github" {
  name               = "${local.prefix}github-${local.github_repo}"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}

data "aws_iam_policy_document" "github" {
  dynamic "statement" {
    for_each = local.statements

    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_policy" "github" {
  name   = "${local.prefix}github-allow-access-to-${local.resource}-from-${local.github_repo}"
  policy = data.aws_iam_policy_document.github.json
}

resource "aws_iam_role_policy_attachment" "github" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github.arn
}

