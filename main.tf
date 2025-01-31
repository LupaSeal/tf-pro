# 1️⃣ Fetching AWS Region
# Gets the current AWS region
data "aws_region" "current" {}

# 2️⃣ Fetching Terraform Remote State
data "terraform_remote_state" "backend" {
  backend = "s3"

  config = {
    bucket         = "tf-pro-cert-bucket-9cefvxxgs8"
    key            = "${terraform.workspace}/terraform.tfstate"
    region         = data.aws_region.current.name
    dynamodb_table = "tf-pro-cert-lock-yq3od59wmm"
  }
}

# 3️⃣ Defining Workspace Values
# Stores different settings for dev, prod, and default
locals {
  workspace_values = {
    dev = {
      environment = "dev"
      value       = "DEV WORKSPACE"
      tags        = { environment = "dev", owner = "devops" }
    }
    prod = {
      environment = "prod"
      value       = "PROD WORKSPACE"
      tags        = { environment = "prod", owner = "sre" }
    }
    default = {
      environment = "default"
      value       = "DEFAULT WORKSPACE"
      tags        = { environment = "default", owner = "no-team-assigned" }
    }
  }

  # Picks the correct values based on the active workspace
  current_values = lookup(local.workspace_values, terraform.workspace, local.workspace_values["default"])
}

# 4️⃣ Creating IAM Policies
# Defines explicit IAM policies without for_each
resource "aws_iam_policy" "s3_list_access" {
  name   = "s3_list_access_${terraform.workspace}"
  path   = "/"
  policy = file("${path.module}/policies/s3_list_access.json")
}

resource "aws_iam_policy" "s3_read_access" {
  name   = "s3_read_access_${terraform.workspace}"
  path   = "/"
  policy = file("${path.module}/policies/s3_read_access.json")
}

# 5️⃣ Creating the IAM Role
resource "aws_iam_role" "test_role" {
  name = "s3_access_role_${terraform.workspace}"

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

# 6️⃣ Attaching IAM Policies to the Role
resource "aws_iam_role_policy_attachment" "s3_list_access_attachment" {
  policy_arn = aws_iam_policy.s3_list_access.arn
  role       = aws_iam_role.test_role.name
  depends_on = [aws_iam_role.test_role]
}

resource "aws_iam_role_policy_attachment" "s3_read_access_attachment" {
  policy_arn = aws_iam_policy.s3_read_access.arn
  role       = aws_iam_role.test_role.name
  depends_on = [aws_iam_role.test_role]
}

# 7️⃣ Creating the AWS SSM Parameter Store Resource
resource "aws_ssm_parameter" "env_parameter" {
  name      = "/${local.current_values.environment}/parameter"
  type      = "String"
  value     = local.current_values.value

  tags = local.current_values.tags
}
