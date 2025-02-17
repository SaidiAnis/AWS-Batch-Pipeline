# Variable for the S3 bucket name where resources will be stored
variable "bucket_name" {
  type        = string
  default     = "aws-pipeline"  # Default bucket name
  description = "The name of the S3 bucket where Lambda functions and other resources will be stored"
}

# Variable for the ARN of a user (likely for access control or permissions)
variable "ARN_User" {
  type        = string
  description = "The ARN of the user to be used for permissions and access control"
}

# Variable for the ARN of the TreatJsonPlaceholderUsers Lambda function
variable "TreatJsonPlaceholderUsers_arn" {
  type        = string
  description = "The ARN of the TreatJsonPlaceholderUsers Lambda function"
}

# Variable for the name of the TreatJsonPlaceholderUsers Lambda function
variable "TreatJsonPlaceholderUsers_name" {
  type        = string
  description = "The name of the TreatJsonPlaceholderUsers Lambda function"
}
