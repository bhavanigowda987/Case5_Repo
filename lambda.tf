resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-ec2-control-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_ec2_policy" {
  name = "lambda-ec2-permission"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_lambda_function" "start_stop_ec2" {
  function_name = "StartStopEC2"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"

  filename         = "${path.module}/lambda_code.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_code.zip")

  timeout     = 10
  memory_size = 128
}
