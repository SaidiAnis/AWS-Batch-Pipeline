# Create ZIP archives for the Lambda functions
resource "archive_file" "zip_StoreJsonPlaceholderUsers" {
  type        = "zip"
  source_dir  = "./modules/lambda/function_1"  # Directory containing Python files and dependencies for StoreJsonPlaceholderUsers
  output_path = "./modules/lambda/StoreJsonPlaceholderUsers.zip"  # Path where the ZIP file will be saved
}

resource "archive_file" "zip_TreatJsonPlaceholderUsers" {
  type        = "zip"
  source_dir  = "./modules/lambda/function_2"  # Directory containing Python files and dependencies for TreatJsonPlaceholderUsers
  output_path = "./modules/lambda/TreatJsonPlaceholderUsers.zip"  # Path where the ZIP file will be saved
}

# Step 1: Upload the ZIP files to S3
resource "aws_s3_object" "lambda_zip_1" {
  bucket = var.bucket_name
  key    = "lambda_function/StoreJsonPlaceholderUsers.zip"  # The name of the file in the S3 bucket
  source = "./modules/lambda/StoreJsonPlaceholderUsers.zip"  # Local path to the ZIP file
  acl    = "private"  # Private access
  depends_on = [archive_file.zip_StoreJsonPlaceholderUsers]  # Ensure the ZIP is uploaded first
}

resource "aws_s3_object" "lambda_zip_2" {
  bucket = var.bucket_name
  key    = "lambda_function/TreatJsonPlaceholderUsers.zip"  # The name of the file in the S3 bucket
  source = "./modules/lambda/TreatJsonPlaceholderUsers.zip"  # Local path to the ZIP file
  acl    = "private"  # Private access
  depends_on = [archive_file.zip_TreatJsonPlaceholderUsers]  # Ensure the ZIP is uploaded first
}

# Step 2: Create Lambda functions using the ZIP files stored in S3
resource "aws_lambda_function" "StoreJsonPlaceholderUsers" {
  function_name = "StoreJsonPlaceholderUsers"  # Lambda function name
  role          = var.lambda_role_arn  # IAM role ARN
  handler       = "StoreJsonPlaceholderUsers.lambda_handler"  # Lambda handler function
  runtime       = "python3.13"  # Lambda runtime version
  s3_bucket     = var.bucket_name  # S3 bucket where the ZIP is stored
  s3_key        = "lambda_function/StoreJsonPlaceholderUsers.zip"  # Path to the ZIP file in S3
  timeout       = 15  # Timeout for the Lambda function

  environment {
    variables = {
      S3_BUCKET = var.bucket_name  # Pass the bucket name as an environment variable to the Lambda function
    }
  }

  depends_on = [aws_s3_object.lambda_zip_1]  # Ensure the ZIP is uploaded first
}

resource "aws_lambda_function" "TreatJsonPlaceholderUsers" {
  function_name = "TreatJsonPlaceholderUsers"  # Lambda function name
  role          = var.lambda_role_arn  # IAM role ARN
  handler       = "TreatJsonPlaceholderUsers.lambda_handler"  # Lambda handler function
  runtime       = "python3.13"  # Lambda runtime version
  s3_bucket     = var.bucket_name  # S3 bucket where the ZIP is stored
  s3_key        = "lambda_function/TreatJsonPlaceholderUsers.zip"  # Path to the ZIP file in S3
  timeout       = 15  # Timeout for the Lambda function

  environment {
    variables = {
      S3_BUCKET = var.bucket_name  # Pass the bucket name as an environment variable to the Lambda function
    }
  }

  depends_on = [aws_s3_object.lambda_zip_2]  # Ensure the ZIP is uploaded first
}
