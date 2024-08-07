resource "aws_sqs_queue" "order_queue" {
  name                       = "order-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_dlq_queue.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "order_dlq_queue" {
  name                       = "order-dlq-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue" "notification_queue" {
  name                       = "notification-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.customer_dlq_queue.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "notification_dlq_queue" {
  name                       = "notification-dlq-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue" "customer_queue" {
  name                       = "customer-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.customer_dlq_queue.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "customer_dlq_queue" {
  name                       = "customer-dlq-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue" "tracking_queue" {
  name                       = "tracking-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.tracking_dlq_queue.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "tracking_dlq_queue" {
  name                       = "tracking-dlq-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue" "payment_queue" {
  name                       = "payment-queue"
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
  name                       = "payment-dlq-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue" "payment_mock_queue" {
  name                       = "payment-mock-queue"
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

resource "aws_sqs_queue_policy" "queue_tracking_policy" {
  queue_url = aws_sqs_queue.payment_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "trackingreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.tracking_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.tracking_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "queue_dlq_tracking_policy" {
  queue_url = aws_sqs_queue.tracking_dlq_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "trackingdlqreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.tracking_dlq_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.tracking_dlq_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "queue_customer_policy" {
  queue_url = aws_sqs_queue.customer_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "customerreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.customer_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.customer_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "queue_dlq_customer_policy" {
  queue_url = aws_sqs_queue.customer_dlq_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "customerdlqreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.customer_dlq_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.customer_dlq_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "queue_notification_policy" {
  queue_url = aws_sqs_queue.notification_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "notificationreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.notification_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.notification_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "queue_dlq_notification_policy" {
  queue_url = aws_sqs_queue.notification_dlq_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "notificationdlqreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.notification_dlq_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.notification_dlq_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "queue_order_policy" {
  queue_url = aws_sqs_queue.order_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "orderreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.order_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.order_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "queue_dlq_order_policy" {
  queue_url = aws_sqs_queue.order_dlq_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "orderdlqreceive",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:ReceiveMessage", "sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.order_dlq_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.order_dlq_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}