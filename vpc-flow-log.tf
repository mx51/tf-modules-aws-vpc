locals {
  vpc_bucket_name = "${aws_vpc.main.id}-${var.flow_log_bucket_name}"
}

resource "aws_flow_log" "main" {
  count                = var.enable_vpc_flow_log ? 1 : 0
  log_destination      = var.send_flow_log_to_external_bucket ? var.flow_log_external_bucket : aws_s3_bucket.flow_log[count.index].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

resource "aws_s3_bucket" "flow_log" {
  count = var.enable_vpc_flow_log == true && var.send_flow_log_to_external_bucket == false ? 1 : 0
  acl   = "private"
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
        sse_algorithm = "AES256"
      }
    }
  }
  tags = merge(
    { Name = "${var.vpc_name}-s3-flow-log-bucket" },
    var.tags
  )
}

