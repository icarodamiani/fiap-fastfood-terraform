resource "aws_apigatewayv2_api" "main" {
  name          = "main"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "dev"
  auto_deploy = true
}

resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id = aws_apigatewayv2_api.main.id

  authorizer_type = "JWT"
  identity_sources = ["$request.header.Authorization"]

  name = "authorizer-${terraform.workspace}"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.name] // TODO verificar aud do token
    issuer = "https://${aws_cognito_user_pool.user_pool.endpoint}"
  }
}

resource "aws_security_group" "vpc_link" {
  name   = "vpc-link"
  vpc_id = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_vpc_link" "eks" {
  name               = "eks"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids = [
    aws_subnet.private-us-east-1a.id
  ]
}