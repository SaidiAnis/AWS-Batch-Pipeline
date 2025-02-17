# Step 1: Install dependencies (via null_resource if required)
resource "null_resource" "install_dependencies_StoreJsonPlaceholderUsers" {
  provisioner "local-exec" {
    command = "pip install -r ../Lambda/StoreJsonPlaceholderUsers/requirements.txt -t ./modules/lambda/StoreJsonPlaceholderUsers/"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "install_dependencies_ProcessJsonPlaceholderUsers" {
  provisioner "local-exec" {
    command = "pip install -r ../Lambda/ProcessJsonPlaceholderUsers/requirements.txt -t ./modules/lambda/ProcessJsonPlaceholderUsers/"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Step 2: Copy Python file into the directory before zipping (for ProcessJsonPlaceholderUsers)
resource "null_resource" "copy_python_file_StoreJsonPlaceholderUsers" {
  provisioner "local-exec" {
    command = "copy ..\\Lambda\\StoreJsonPlaceholderUsers\\StoreJsonPlaceholderUsers.py .\\modules\\lambda\\StoreJsonPlaceholderUsers\\"
  }

  depends_on = [null_resource.install_dependencies_StoreJsonPlaceholderUsers]  # Ensure dependencies are installed first

  triggers = {
    always_run = "${timestamp()}"
  }
}
resource "null_resource" "copy_python_file_ProcessJsonPlaceholderUsers" {
  provisioner "local-exec" {
    command = "copy ..\\Lambda\\ProcessJsonPlaceholderUsers\\ProcessJsonPlaceholderUsers.py .\\modules\\lambda\\ProcessJsonPlaceholderUsers\\"
  }

  depends_on = [null_resource.install_dependencies_ProcessJsonPlaceholderUsers]  # Ensure dependencies are installed first

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Step 3: Create ZIP archives for the Lambda functions
resource "archive_file" "zip_StoreJsonPlaceholderUsers" {
  type        = "zip"
  source_dir  = "./modules/lambda/StoreJsonPlaceholderUsers"  # Directory containing Python files and dependencies for StoreJsonPlaceholderUsers
  output_path = "./modules/lambda/StoreJsonPlaceholderUsers.zip"  # Path where the ZIP file will be saved

  depends_on = [null_resource.install_dependencies_StoreJsonPlaceholderUsers]  # Ensure dependencies are installed before zipping
}

resource "archive_file" "zip_ProcessJsonPlaceholderUsers" {
  type        = "zip"
  source_dir  = "./modules/lambda/ProcessJsonPlaceholderUsers"  # Directory containing Python files and dependencies for ProcessJsonPlaceholderUsers
  output_path = "./modules/lambda/ProcessJsonPlaceholderUsers.zip"  # Path where the ZIP file will be saved

  depends_on = [null_resource.copy_python_file_ProcessJsonPlaceholderUsers]  # Ensure Python file is copied before zipping
}

# Step 4: Upload the ZIP files to S3
resource "aws_s3_object" "lambda_zip_1" {
  bucket = var.bucket_name
  key    = "lambda_function/StoreJsonPlaceholderUsers.zip"  # The name of the file in the S3 bucket
  source = "./modules/lambda/StoreJsonPlaceholderUsers.zip"  # Local path to the ZIP file
  acl    = "private"  # Private access
  depends_on = [archive_file.zip_StoreJsonPlaceholderUsers]  # Ensure the ZIP is uploaded first
}

resource "aws_s3_object" "lambda_zip_2" {
  bucket = var.bucket_name
  key    = "lambda_function/ProcessJsonPlaceholderUsers.zip"  # The name of the file in the S3 bucket
  source = "./modules/lambda/ProcessJsonPlaceholderUsers.zip"  # Local path to the ZIP file
  acl    = "private"  # Private access
  depends_on = [archive_file.zip_ProcessJsonPlaceholderUsers]  # Ensure the ZIP is uploaded first
}

# Step 5: Create Lambda functions using the ZIP files stored in S3
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

resource "aws_lambda_function" "ProcessJsonPlaceholderUsers" {
  function_name = "ProcessJsonPlaceholderUsers"  # Lambda function name
  role          = var.lambda_role_arn  # IAM role ARN
  handler       = "ProcessJsonPlaceholderUsers.lambda_handler"  # Lambda handler function
  runtime       = "python3.13"  # Lambda runtime version
  s3_bucket     = var.bucket_name  # S3 bucket where the ZIP is stored
  s3_key        = "lambda_function/ProcessJsonPlaceholderUsers.zip"  # Path to the ZIP file in S3
  timeout       = 15  # Timeout for the Lambda function

  environment {
    variables = {
      S3_BUCKET = var.bucket_name  # Pass the bucket name as an environment variable to the Lambda function
    }
  }

  depends_on = [aws_s3_object.lambda_zip_2]  # Ensure the ZIP is uploaded first
}
