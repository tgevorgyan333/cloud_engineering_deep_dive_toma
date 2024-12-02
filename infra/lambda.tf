
# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.lambda_function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Package the Lambda Code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.js"
  output_path = "${path.module}/lambda_function.zip"
}



# Create Lambda Function
resource "aws_lambda_function" "hello_world" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.handler"
  runtime       = "nodejs18.x"
# Fetch the Lambda zip file from S3
  s3_bucket = data.aws_s3_bucket.existing_bucket.bucket
  s3_key    = "lambda_function.zip"
  # Compute the hash from the S3 object
  source_code_hash = filebase64sha256("../src/lambda/lambda_function.js")
}

data "aws_s3_bucket" "existing_bucket" {
  bucket = "myawsbucket-toma"  # Replace with your existing bucket name
}

# IAM Role for GitHub Actions with OIDC
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/lambdas-dev-branch"
          }
        }
      }
    ]
  })
}

# Attach S3 permissions to the role
resource "aws_iam_policy" "s3_access_policy" {
  name = "github-actions-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

data "aws_caller_identity" "current" {}
