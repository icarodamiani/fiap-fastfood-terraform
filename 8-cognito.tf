
// Resources
resource "aws_cognito_user_pool" "fiap-g86-user-pool" {
  name = "fiap-g86-user-pool"

  password_policy {
    minimum_length = 6
  }

  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration {
    enabled = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Account Confirmation"
    email_message        = "Your confirmation code is {####}"
  }
}

resource "aws_cognito_user_pool_client" "fiap-g86-cognito-client" {
  name = "fiap-g86-cognito-client"

  user_pool_id                  = aws_cognito_user_pool.fiap-g86-user-pool.id
  generate_secret               = true
  refresh_token_validity        = 90
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

}

resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.fiap-g86-user-pool.id
}