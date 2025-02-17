variable "bucket_name" {
  description = "S3 bucket where Lambda's ZIP file is stored"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the IAM role assigned to Lambda"
  type        = string
}
