resource "aws_sqs_queue" "payment_queue" {
  name                       = "payment_queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.payment_dlq_queue.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "payment_dlq_queue" {
  name                       = "payment_dlq_queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue" "payment_mock_queue" {
  name                       = "payment_mock_queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue_policy" "queue_payment_policy" {
  queue_url = aws_sqs_queue.payment_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "paymentreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.payment_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.payment_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "queue_dlq_payment_policy" {
  queue_url = aws_sqs_queue.payment_dlq_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "paymentdlqreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.payment_dlq_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.payment_dlq_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "queue_mock_payment_policy" {
  queue_url = aws_sqs_queue.payment_mock_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "paymentmockreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.payment_mock_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.payment_mock_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}