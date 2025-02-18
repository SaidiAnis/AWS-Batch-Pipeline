variable "bucket_name" {
  description = "S3 bucket where Lambda's ZIP file is stored"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the IAM role assigned to Lambda"
  type        = string
}

variable "copy_command_ProcessJsonPlaceholderUsers" {
  type = string
  default = "copy ..\\Lambda\\ProcessJsonPlaceholderUsers\\ProcessJsonPlaceholderUsers.py .\\modules\\lambda\\ProcessJsonPlaceholderUsers\\"
}

variable "copy_command_StoreJsonPlaceholderUsers" {
  type = string
  default = "copy ..\\Lambda\\StoreJsonPlaceholderUsers\\StoreJsonPlaceholderUsers.py .\\modules\\lambda\\StoreJsonPlaceholderUsers\\"
}