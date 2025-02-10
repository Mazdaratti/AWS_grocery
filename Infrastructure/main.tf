provider "aws" {
  region = "eu-central-1"
  profile = "default"
}


# S3 Bucket
resource "aws_s3_bucket" "grocery_s3" {
  bucket = "andreys-grocery-s3"

  tags = {
    Name        = "andreys-grocery-s3"
    Environment = "Production"
  }
}

#resource "aws_s3_bucket_versioning" "grocery_s3_versioning" {
  #bucket = aws_s3_bucket.grocery_s3.id
  #versioning_configuration {
    #status = "Enabled"
  #}
#}

#resource "aws_s3_bucket_lifecycle_configuration" "grocery_s3_lifecycle" {
  #bucket = aws_s3_bucket.grocery_s3.id

  #rule {
    #id     = "expire-old-avatars"
    #status = "Enabled"

    #filter {
      #prefix = "avatars/"
    #}

    #expiration {
      #days = 30  # Delete objects in the avatars/ folder after 30 days
    #}
  #}
#}

# Creating an empty "avatars/" folder (simulated with an empty object)
resource "aws_s3_object" "avatars_folder" {
  bucket = aws_s3_bucket.grocery_s3.id
  key    = "avatars/"
}

resource "aws_s3_bucket_public_access_block" "grocery_s3_block" {
  bucket = aws_s3_bucket.grocery_s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
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
      "Resource": "arn:aws:s3:::andreys-grocery-s3/avatars/*"
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
  bucket = "andreys-grocery-s3"
  key    = "avatars/user_default.png"  # Path inside the bucket
  source = "../backend/avatar/user_default.png"  # Local file path
}


