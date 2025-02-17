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

#s3 bucket notification to start a lambda function
resource "aws_s3_bucket_notification" "s3_to_lambda" {
  bucket = aws_s3_bucket.batch.id

  lambda_function {
    lambda_function_arn = var.TreatJsonPlaceholderUsers_arn
    events              = ["s3:ObjectCreated:*"]  
    filter_prefix       = "raw/users/"           
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

#give to s3 permission to invoke lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.TreatJsonPlaceholderUsers_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.batch.arn
}

