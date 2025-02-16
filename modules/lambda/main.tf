resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "./modules/lambda/lambda_project"  # Le dossier contenant tes fichiers Python et autres dépendances
  output_path = "./modules/lambda/StoreJsonPlaceholderUsers.zip"  # Le chemin où le fichier zip sera sauvegardé
}


# Step 1: Upload the lambda ZIP file to S3
resource "aws_s3_object" "lambda_zip" {
  bucket = var.bucket_name
  key    = "lambda_function/StoreJsonPlaceholderUsers.zip"  # Le nom du fichier dans le bucket
  source = "./modules/lambda/StoreJsonPlaceholderUsers.zip" # Chemin local vers ton fichier ZIP
  acl    = "private"  # Accès privé
  depends_on = [archive_file.lambda_zip]  # Ensure the ZIP is uploaded first
}

# Step 2: Create the Lambda function using the ZIP in S3
resource "aws_lambda_function" "StoreJsonPlaceholderUsers" {
  function_name = var.function_name  # Lambda function name
  role          = var.lambda_role_arn  # IAM role ARN
  handler       = "StoreJsonPlaceholderUsers.lambda_handler"  # Handler function
  runtime       = "python3.13"  # Lambda runtime
  s3_bucket     = var.bucket_name  # S3 bucket for the zip
  s3_key        = "lambda_function/StoreJsonPlaceholderUsers.zip"    # Path to the zip in S3
  timeout       = 30

  environment {
  variables = {
    S3_BUCKET = var.bucket_name # Pass the bucket name as an environment variable
  }
}

depends_on = [aws_s3_object.lambda_zip]  # Ensure the ZIP is uploaded first

}
