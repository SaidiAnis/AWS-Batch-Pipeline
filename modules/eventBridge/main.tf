resource "aws_cloudwatch_event_rule" "daily_rule" {
  name                 = var.rule_name
  description          = var.description
  schedule_expression  = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.daily_rule.name
  arn  = var.lambda_function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_rule.arn
}


# IAM Role for EventBridge to invoke Lambda
resource "aws_iam_role" "eventbridge_lambda_role" {
  name               = "eventbridge-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role_policy.json
}

# IAM policy document for EventBridge to assume the role
data "aws_iam_policy_document" "eventbridge_assume_role_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}