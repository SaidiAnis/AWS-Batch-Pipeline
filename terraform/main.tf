provider "aws" {
  region = "us-west-2"
}

module "iam" {
  source     = "./modules/iam"
  bucket_name =  module.s3_bucket.bucket_id
  ARN_User = var.ARN_User
}


module "s3_bucket" {
  source = "./modules/s3"
  ARN_User = var.ARN_User
  ProcessJsonPlaceholderUsers_name = module.lambda.ProcessJsonPlaceholderUsers_name
  ProcessJsonPlaceholderUsers_arn = module.lambda.ProcessJsonPlaceholderUsers_arn
}

module "lambda" {
  source = "./modules/lambda"
  bucket_name     = module.s3_bucket.bucket_id
  lambda_role_arn = module.iam.lambda_role_arn
}

module "eventbridge" {
  source              = "./modules/eventBridge"
  rule_name           = "daily-event-rule"
  description         = "Trigger Lambda every day at 10 AM UTC+1"
  schedule_expression = "cron(00 09 * * ? *)" 
  lambda_function_arn = module.lambda.StoreJsonPlaceholderUsers_arn
  lambda_function_name = module.lambda.StoreJsonPlaceholderUsers_name
}

module "glue" {
  source        = "./modules/glue"
  database_name = "my_glue_database"
  bucket_name   = module.s3_bucket.bucket_id
  glue_role_arn = module.iam.glue_role_arn

}

module "athena" {
  source        = "./modules/athena"
  s3_output_bucket = module.s3_bucket.bucket_id
}
