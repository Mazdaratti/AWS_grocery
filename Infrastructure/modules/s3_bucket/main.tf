resource "aws_s3_bucket" "grocery_s3" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "grocery_s3_versioning" {
  bucket = aws_s3_bucket.grocery_s3.id
  versioning_configuration {
    status = var.versioning_status
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "grocery_s3_lifecycle" {
  bucket = aws_s3_bucket.grocery_s3.id

  rule {
    id     = "expire-old-avatars"
    status = var.lifecycle_status

    filter {
      prefix = var.prefix
    }

    expiration {
      days = var.expiration_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "grocery_s3_block" {
  bucket = aws_s3_bucket.grocery_s3.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_policy" "avatars_policy" {
  bucket = aws_s3_bucket.grocery_s3.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.grocery_s3.bucket}/${var.prefix}*"
    }
  ]
}
POLICY
  depends_on = [aws_s3_bucket_public_access_block.grocery_s3_block]
}

resource "aws_s3_bucket_cors_configuration" "avatars_cors" {
  bucket = aws_s3_bucket.grocery_s3.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_object" "avatar_image" {
  bucket = aws_s3_bucket.grocery_s3.id
  key    = "${var.prefix}${var.avatar_filename}"
  source = var.avatar_path
}
