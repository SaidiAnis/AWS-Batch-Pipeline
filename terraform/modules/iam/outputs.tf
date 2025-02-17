output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}