# IAM Policy document for Lambda to assume the role
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# IAM Policy document for Lambda S3 access
data "aws_iam_policy_document" "s3_lambda_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    effect    = "Allow"
  }
}

# IAM Policy document for Lambda CloudWatch Logs access
data "aws_iam_policy_document" "cloudwatch_lambda_policy" {
  statement {
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }
}

# Create Lambda role
resource "aws_iam_role" "lambda_role" {
  name               = "lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# Define the policy for S3 access
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-s3-policy"
  description = "Policy allowing Lambda to interact with S3"
  policy      = data.aws_iam_policy_document.s3_lambda_policy.json
}

# Define the policy for CloudWatch Logs access
resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  name        = "lambda-cloudwatch-policy"
  description = "Policy allowing Lambda to write logs to CloudWatch"
  policy      = data.aws_iam_policy_document.cloudwatch_lambda_policy.json
}

# Attach the S3 access policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Attach the CloudWatch access policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy.arn
}


#--------------------------------------- Glue + Crawler role
resource "aws_iam_role" "glue_role" {
  name = "glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "glue_combined_policy" {
  name        = "glue-combined-policy"
  description = "Combined policy for Glue crawler and Glue operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permissions to access S3
      {
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/processed/users/*"
        ]
      },
      # Permissions for Glue to manage tables, partitions, and databases
      {
        Action   = ["glue:CreateTable", "glue:GetTable", "glue:UpdateTable", "glue:DeleteTable", "glue:BatchCreatePartition", "glue:BatchDeletePartition", "glue:CreateDatabase", "glue:GetDatabase"]
        Effect   = "Allow"
        Resource = "*"
      },
      # Permissions for CloudWatch logs
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_combined_policy.arn
}
  