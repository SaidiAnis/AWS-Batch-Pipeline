variable "workgroup_name" {
  type        = string
  description = "The name of the Athena workgroup"
  default = "my_first_workgroup"
}

variable "s3_output_bucket" {
  type        = string
  description = "The S3 bucket to store Athena query results"
}
