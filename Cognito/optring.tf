resource "aws_cognito_user_pool" "pool" {
  name = "optring.io"
}

resource "aws_cognito_user_pool_client" "web-ui" {
  generate_secret = true
  name            = "api"

  user_pool_id = aws_cognito_user_pool.pool.id
}
