# See variables.tf or README.md for variable descriptions as well as additional
# variables you can customize in this file.
app_name = "getfib"
infra_tf_s3_bucket = "ja-tf-bucket"

# ECR
# ecr_override_image_url below is set for initial terraform bootstrap.
# You should delete or comment this out when you have pushed an image to ecr
# that you would like to use instead.
#ecr_override_image_url = "113421050194.dkr.ecr.us-east-2.amazonaws.com/getfib-repo:600c3aa"
ecr_image_tag = "600c3aa"
# 113421050194.dkr.ecr.us-east-2.amazonaws.com/getfib-repo:600c3aa

# ECS
ecs_autoscaling_min_capacity = 1
ecs_autoscaling_max_capacity = 1

# Load balancer
# replace alb_allowed_list with your IP.
# You can find your IP by running: curl ipv4.wtfismyip.com/text
alb_allowed_list = ["67.176.242.109/32"]
