# ECS Cluster
locals {
  ecr_image = coalesce(var.ecr_override_image_url,
  "${data.terraform_remote_state.infra.outputs.ecr_repo_url}:${var.ecr_image_tag}")

}
