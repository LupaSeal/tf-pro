output "iam_role_arn" {
  value = aws_iam_role.test_role.arn
}

output "iam_role_id" {
  value = aws_iam_role.test_role.name
}

output "iam_policies" {
  value = { for name, policy in aws_iam_policy.s3_policies : name => policy.arn }
}

