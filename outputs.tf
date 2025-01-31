output "iam_role_arn" {
  value = aws_iam_role.test_role.arn
}

output "iam_role_id" {
  value = aws_iam_role.test_role.name
}

output "iam_policies" {
  value = {
    s3_list_access = aws_iam_policy.s3_list_access.arn
    s3_read_access = aws_iam_policy.s3_read_access.arn
  }
}

output "remote_state_content" {
  value = data.terraform_remote_state.backend.outputs
}
