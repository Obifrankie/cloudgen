# This houses the value of secrets stored in AWS secret manager please create a new secret in secret manager and replace the place holders here.

data "aws_secretsmanager_secret" "db_password_secret" {
  arn = "<ARN_OF_DB_PASSWORD_SECRET>"
}

data "aws_secretsmanager_secret" "db_username_secret" {
  arn = "<ARN_OF_DB_USERNAME_SECRET>"
}

data "aws_secretsmanager_secret" "key_pair_secret" {
  arn = "<ARN_OF_KEY_PAIR_SECRET>"
}
