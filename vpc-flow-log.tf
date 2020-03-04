locals {
  vpc_bucket_name = "${aws_vpc.main.id}-${var.flow_log_bucket_name}"
}

data "aws_iam_policy_document" "log_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "log_policy" {
  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:DeleteDelivery"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "vpc_flow_log_policy" {

  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    principals {
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
      type = "Service"
    }
    resources = ["arn:aws:s3:::${local.vpc_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl"
    ]
    principals {
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
      type = "Service"
    }
    resources = ["arn:aws:s3:::${local.vpc_bucket_name}"]
  }
}

data "aws_iam_policy_document" "kms_role_policy" {
  statement {
    sid    = "Allow administration of the key"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.client_name}-role-api-fulladmin",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.client_name}-role-console-breakglass",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/victor-cmd"
      ]
      type = "AWS"
    }
    resources = ["*"]
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.client_name}-role-console-breakglass"
      ]
      type = "AWS"
    }
    resources = ["*"]
  }

  statement {
    sid    = "Allow VPC Flow Logs to use the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
      type = "Service"
    }
    resources = ["*"]
  }

  statement {
    sid    = "AllowExternalAccountAccess"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    resources = ["*"]
  }

  statement {
    sid    = "AllowExternalAccountsToAttachPersistentResources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_flow_log" "main" {
  count                = var.enable_vpc_flow_log ? 1 : 0
  iam_role_arn         = aws_iam_role.log[count.index].arn
  log_destination      = aws_s3_bucket.flow_log[count.index].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

resource "aws_iam_role" "log" {
  count              = var.enable_vpc_flow_log ? 1 : 0
  name               = "iam-flow-log-role"
  assume_role_policy = data.aws_iam_policy_document.log_assume.json
  tags = merge(
    { Name = "${var.vpc_name}-flow-log-role" },
    var.tags
  )
}

resource "aws_iam_role_policy" "log" {
  count  = var.enable_vpc_flow_log ? 1 : 0
  name   = var.vpc_name
  role   = aws_iam_role.log[count.index].id
  policy = data.aws_iam_policy_document.log_policy.json
}

resource "aws_s3_bucket" "flow_log" {
  count  = var.enable_vpc_flow_log == true ? 1 : 0
  bucket = local.vpc_bucket_name
  acl    = "log-delivery-write"
  versioning {
    enabled = var.enable_bucket_versioning
  }

  lifecycle_rule {
    enabled = var.enable_lifecycle_rule
    prefix  = var.lifecycle_prefix
    tags    = var.lifecycle_tags
    noncurrent_version_expiration {
      days = var.noncurrent_version_expiration_days
    }
    noncurrent_version_transition {
      days          = var.noncurrent_version_transition_days
      storage_class = "GLACIER"
    }
    transition {
      days          = var.standard_transition_days
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }
    expiration {
      days = var.expiration_days
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.s3_bucket_key[count.index].key_id
      }
    }
  }
  tags = merge(
    { Name = "${var.vpc_name}-s3-flow-log-bucket" },
    var.tags
  )
}

resource "aws_s3_bucket_policy" "vpc_flow_logging_policy" {
  count  = var.enable_vpc_flow_log == true ? 1 : 0
  bucket = aws_s3_bucket.flow_log[count.index].id
  policy = data.aws_iam_policy_document.vpc_flow_log_policy.json
}

resource "aws_kms_key" "s3_bucket_key" {
  count                   = var.enable_vpc_flow_log == true ? 1 : 0
  description             = "KMS Key for S3 bucket"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.kms_role_policy.json
  tags = merge(
    { Name = "${var.vpc_name}-s3-kms-key" },
    var.tags
  )
}
