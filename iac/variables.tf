variable "app_name" {
  description = "Name used across resources created"
  type        = string
}

variable "infra_tf_s3_bucket" {
  description = "S3 bucket holding infrastructure state"
  type        = string
}

variable "ecr_image_tag" {
  description = "ECR image tag"
  type        = string
  default     = "latest"
}

variable "ecr_override_image_url" {
  description = "ECR image url to use in task definition instead of standard image based on pattern."
  type        = string
  default     = null
}

# ALB
variable "alb_tags" {
  description = "A map of tags to add to all alb resources"
  type        = map(string)
  default     = {}
}

# ecs
variable "ecs_tags" {
  description = "A map of tags to add to all ecs resources"
  type        = map(string)
  default     = {}
}

variable "alb_allowed_list" {
  description = "A list of CIDR blocks to allow access to the ALB"
  type        = list(string)
  default     = null
}

variable "ecs_autoscaling_min_capacity" {
  description = "Minimum number of tasks to run in your service"
  type        = number
  default     = 1
}

variable "ecs_autoscaling_max_capacity" {
  description = "Maximum number of tasks to run in your service"
  type        = number
  default     = 1
}

variable "ecs_autoscaling_policies" {
  description = "Map of autoscaling policies to create for the service"
  type        = any
  default = {
    cpu = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
      }
    }
    memory = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
      }
    }
  }
}

variable "ecs_autoscaling_scheduled_actions" {
  description = "Map of autoscaling scheduled actions to create for the service"
  type        = any
  default     = {}
}
