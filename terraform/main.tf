locals {
  prefix            = "TF-"  #Prefix for Roles & Policies
  #oidc_provider_arn = "arn:aws:iam::${var.aws_account}:oidc-provider/token.actions.githubusercontent.com" 
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

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  client_id_list  = ["sts.amazonaws.com"]
}

#Github OIDC connection provider
#data "aws_iam_openid_connect_provider" "github" {
#  arn = local.oidc_provider_arn
#}

#Policy document for github integration
data "aws_iam_policy_document" "github_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      #identifiers = [local.oidc_provider_arn]
      identifiers = [aws_iam_openid_connect_provider.github.arn]
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

#AWS role for github integration
resource "aws_iam_role" "github" {
  name               = "${local.prefix}github-${local.github_repo}"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}

#Policy document for EC2 management
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

#AWS Policy generated from Policy Document
resource "aws_iam_policy" "github" {
  name   = "${local.prefix}github-allow-access-to-${local.resource}-from-${local.github_repo}"
  policy = data.aws_iam_policy_document.github.json
}

#Attach polocy to AWS role
resource "aws_iam_role_policy_attachment" "github" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github.arn
}

