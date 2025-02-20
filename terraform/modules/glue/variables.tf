# Variable for the name of the Glue database to be created or accessed
variable "database_name" {
  description = "The name of the Glue database"
  type        = string
}

# Variable for the cron schedule to run the Glue crawler (default is every day at 11 AM UTC+1)
variable "schedule" {
  description = "The cron schedule for the Glue crawler"
  type        = string
  default     = "cron(00 10 * * ? *)"  # Default to every day at 11 AM UTC+1
}

# Variable for the ARN of the IAM role to be used by the Glue crawler
variable "glue_role_arn" {
  description = "The ARN of the IAM role for the Glue crawler"
  type        = string
}

# Variable for the S3 bucket name where the data to be crawled is stored
variable "bucket_name" {
  description = "The name of the S3 bucket where processed data is stored"
  type        = string
}
