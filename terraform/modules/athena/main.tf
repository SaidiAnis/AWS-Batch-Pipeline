resource "aws_athena_workgroup" "default" {
  name = var.workgroup_name

  configuration {
    result_configuration {
      output_location = "s3://${var.s3_output_bucket}/athena/results/"
    }
  }

  state = "ENABLED"
}
