#random string for the unique s3 bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "batch" {
  bucket =  "${var.bucket_name}-${random_string.bucket_suffix.result}"
  
}

# Bucket Policy to control access
resource "aws_s3_bucket_policy" "d3_policy" {
  bucket = aws_s3_bucket.batch.id

  policy = data.aws_iam_policy_document.s3_PUT_GET_policy.json
}

# IAM Policy document for defining access control
data "aws_iam_policy_document" "s3_PUT_GET_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = [
      "${aws_s3_bucket.batch.arn}/*"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.ARN_User]
    }
  }
}
