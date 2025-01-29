# Fetch the current AWS region
data "aws_region" "current" {}

locals {
  # Define policy names that match actual JSON files in ./policies/
  policy_names = {
    s3_list_access = "s3_list_access"
    s3_read_access = "s3_read_access"
  }
}

# IAM Policies: Create policies dynamically from JSON files
resource "aws_iam_policy" "s3_policies" {
  for_each = local.policy_names

  name   = each.key
  path   = "/"
  policy = file("${path.module}/policies/${each.value}.json")
}

# IAM Role: Creates an IAM role
resource "aws_iam_role" "test_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Region = data.aws_region.current.name
  }
}

# IAM Role-Policy Attachments: Attach all generated policies to the IAM role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  for_each = aws_iam_policy.s3_policies

  policy_arn = each.value.arn
  role       = aws_iam_role.test_role.name
}
