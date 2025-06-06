output "tf_state_kms_id" {
  description = "ID of the KMS key used to encrypt bucket objects"
  value       = aws_kms_key.tf-bucket-key.id
}

output "tf_state_kms_alias" {
  description = "Alias of the KMS key used to encrypt bucket objects"
  value       = aws_kms_alias.key-alias.id
}

output "tf_state_kms_arn" {
  description = "value of the ARN of the KMS key used to encrypt bucket objects"
  value       = aws_kms_key.tf-bucket-key.arn
}

output "tf_state_s3_bucket_id" {
  description = "Name (id) of the S3 bucket used to store the terraform state"
  value       = aws_s3_bucket.tf-state.id
}

output "tf_state_s3_bucket_arn" {
  description = "ARN of the S3 bucket used to store the terraform state"
  value       = aws_s3_bucket.tf-state.arn
}

output "tf_state_dynamodb_table_id" {
  description = "Name (id) of the DynamoDB table used to store the terraform state"
  value       = aws_dynamodb_table.tf-state.id
}

output "tf_state_dynamodb_table_arn" {
  description = "ARN of the DynamoDB table used to store the terraform state"
  value       = aws_dynamodb_table.tf-state.arn
}
