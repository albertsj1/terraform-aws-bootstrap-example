data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket         = var.infra_tf_s3_bucket
    key            = "${var.app_name}/account_setup02.tfstate"
    region         = data.aws_region.current.name
    dynamodb_table = "tf-state"
    kms_key_id     = "alias/tf-bucket-key"
    encrypt        = true
  }
  lifecycle {
    postcondition {
      condition     = self.outputs.ecr_repo_url != null
      error_message = "Ecr repo url is not set."
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
