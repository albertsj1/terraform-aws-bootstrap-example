# Creating the app ecr repo here as part of account setup because this avoids
# a chicken/egg scenario for the docker image used by the ecs task definition.
# I've chosen to NOT create and upload the image as part of the IAC code because
# it is important to separate the infrastructure code as much as possible from
# the application code.
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  repository_name = "${var.app_name}-repo"

  repository_read_write_access_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  repository_image_tag_mutability   = "MUTABLE"
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 990,
        description  = "Keep untagged images for 7 days",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 7
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# File to build docker image and push to ecr
# NOTE: Creating this file here does not normally make sense. It would not be part of account setup. It is here to help testing of this example code.
#  Normally, the dev would know what ecr repo they would be using and they would create this file themselves.
resource "local_file" "docker_bp_ecr" {
  filename        = "${path.module}/../../docker_build_push.sh"
  file_permission = "0755"
  content         = <<EOF
#!/bin/bash
set -euo pipefail

# This script creates a docker image of the app and pushes it to ecr
# It will tag the image with the current SHA.
# Repeated builds and pushes of the same SHA will overwrite previous images with the same SHA.

cd "$(dirname "${0}")"

ECR_REPO="${module.ecr.repository_url}"
SHA="$(git rev-parse --short HEAD)"
IMAGE="$${ECR_REPO}:$${SHA}"

docker build -t "$${IMAGE}" .

aws ecr get-login-password --region ${data.aws_region.current.name} | \
docker login --username AWS --password-stdin $${ECR_REPO}

docker push $${IMAGE}

echo "Built and pushed to ecr: $${IMAGE}"

EOF
}
