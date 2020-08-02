resource "aws_lambda_function" "ec2status-lambda" {
   function_name = "ec2status"
   filename      = "ec2status-function.py.zip"
   role          = "arn:aws:iam::680558138144:role/ecs-lambda"
   handler       = "ec2status-function.lambda_handler"
   timeout       = "10"
   runtime       = "python3.8"

  tags = {
    Owner = var.Owner
    Project = var.Project
  }
}


resource "aws_cloudwatch_event_rule" "ec2status-schedule" {
   name                = "ec2status-schedule"
   description         = "execute EC2 status every 1 hour"
   schedule_expression = "rate(1 hour)"
  tags = {
    Owner = var.Owner
    Project = var.Project
  }
}


resource "aws_cloudwatch_event_target" "ec2status-target" {
   rule = aws_cloudwatch_event_rule.ec2status-schedule.name
   arn  = aws_lambda_function.ec2status-lambda.arn
}


resource "aws_lambda_permission" "ec2status-caller" {
   statement_id  = "AllowExecutionFromCloudWatch"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.ec2status-lambda.function_name
   principal     = "events.amazonaws.com"
   source_arn    = aws_cloudwatch_event_rule.ec2status-schedule.arn
}


