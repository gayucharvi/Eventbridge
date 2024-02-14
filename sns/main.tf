terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #      version = "~> 3.0"
    }
 }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" #insert your region code
}
resource "aws_cloudwatch_event_rule" "eventtosns" {
  name = "eventtosns"
  event_pattern = jsonencode(
    {
      account = [
        "", #insert  your account number
      ]

    }
  )
}
resource "aws_cloudwatch_event_target" "eventtosns" {
  # arn of the target and rule id of the eventrule
  arn       = aws_sns_topic.eventtosns.arn
  target_id = "SendToSNS"
  rule      = aws_cloudwatch_event_rule.eventtosns.id
  #input_transformer {
  #  input_paths = {
  #    Source      = "$.source",
  #    detail-type = "$.detail-type",
  #    resources   = "$.resources",
  #    state       = "$.detail.state",
  #    status      = "$.detail.status"
  #  }
  #  input_template = <<EOF
  #{
  #"Resource name" : <Source>,
  #"Action name" : <detail-type>,
  #"details" : <status>, 
  #"Arn" : <resources>
  #  }
  #EOF
  #  }
}
resource "aws_sns_topic" "eventtosns" {
  name = "eventtosns"
}
resource "aws_sns_topic_subscription" "snstoemail_email-target" {
  topic_arn = aws_sns_topic.eventtosns.arn
  protocol  = "email"
  endpoint  = "praveenpravo08@gmail.com"
}


resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.eventtosns.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.eventtosns.arn]
  }
}
