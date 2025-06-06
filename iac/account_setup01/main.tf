data "aws_region" "current" {}

# S3 bucket to store terraform state
resource "aws_s3_bucket" "tf-state" {
  bucket = var.bucket_name
}

# KMS key to encrypt bucket objects
resource "aws_kms_key" "tf-bucket-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# Alias of the KMS key for easier reference
resource "aws_kms_alias" "key-alias" {
  name          = "alias/tf-bucket-key"
  target_key_id = aws_kms_key.tf-bucket-key.key_id
}

# Block all public access to the S3 bucket holding our terraform state
resource "aws_s3_bucket_public_access_block" "tf-state" {
  bucket                  = aws_s3_bucket.tf-state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ACLs enabled
resource "aws_s3_bucket_ownership_controls" "tf-state" {
  bucket = aws_s3_bucket.tf-state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Enable versioning for objects in the bucket
resource "aws_s3_bucket_versioning" "tf-state" {
  bucket = aws_s3_bucket.tf-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt objects in the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "tf-state" {
  bucket = aws_s3_bucket.tf-state.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf-bucket-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Save money by transitioning old objects to cheaper storage
resource "aws_s3_bucket_lifecycle_configuration" "tf-state" {
  bucket = aws_s3_bucket.tf-state.id
  rule {
    id     = "archive"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

# Used for locking terraform state
resource "aws_dynamodb_table" "tf-state" {
  name         = "tf-state"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Write a terraform file to the account_setup02 dir to tell terraform where to store state
resource "local_file" "state01" {
  filename        = "${path.module}/../account_setup02/autogen_state.tf"
  file_permission = "0640"
  content         = <<EOF
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.tf-state.id}"
    key            = "${var.app_name}/account_setup02.tfstate"
    region         = "${data.aws_region.current.name}"
    dynamodb_table = "${aws_dynamodb_table.tf-state.id}"
    kms_key_id     = "${aws_kms_alias.key-alias.id}"
    encrypt        = true
  }
}
EOF
}

# Write a terraform file to the root iac dir to tell terraform where to store state
resource "local_file" "state02" {
  filename        = "${path.module}/../autogen_state.tf"
  file_permission = "0640"
  content         = <<EOF
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.tf-state.id}"
    key            = "${var.app_name}/app.tfstate"
    region         = "${data.aws_region.current.name}"
    dynamodb_table = "${aws_dynamodb_table.tf-state.id}"
    kms_key_id     = "${aws_kms_alias.key-alias.id}"
    encrypt        = true
  }
}
EOF
}
