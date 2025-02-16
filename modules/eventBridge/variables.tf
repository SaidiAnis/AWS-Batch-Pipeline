variable "rule_name" {
  description = "The name of the EventBridge rule"
  type        = string
}

variable "description" {
  description = "Description of the EventBridge rule"
  type        = string
}

variable "schedule_expression" {
  description = "Cron expression for scheduling the event"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to be triggered"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to be triggered"
  type        = string
}
