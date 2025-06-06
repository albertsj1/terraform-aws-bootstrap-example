variable "bucket_name" {
  type    = string
  description = "Name of the S3 bucket for storing Terraform state"
}

variable "app_name" {
  type    = string
  description = "This will be used throughout terraform to uniquely identify resources"
}
