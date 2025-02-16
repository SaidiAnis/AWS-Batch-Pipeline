variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket where Lambda's ZIP file is stored"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the IAM role assigned to Lambda"
  type        = string
}
