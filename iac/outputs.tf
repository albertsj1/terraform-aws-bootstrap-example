output "vpc_id" {
  description = "vpc id"
  value       = data.terraform_remote_state.infra.outputs.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = data.terraform_remote_state.infra.outputs.private_subnets
}

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.ecs_cluster.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs_cluster.id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.ecs_cluster.name
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.ecs_cluster.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = module.ecs_cluster.cloudwatch_log_group_arn
}

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = module.ecs_cluster.cluster_capacity_providers
}

output "autoscaling_capacity_providers" {
  description = "Map of autoscaling capacity providers created and their attributes"
  value       = module.ecs_cluster.autoscaling_capacity_providers
}

output "task_exec_iam_role_name" {
  description = "Task execution IAM role name"
  value       = module.ecs_cluster.task_exec_iam_role_name
}

output "task_exec_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = module.ecs_cluster.task_exec_iam_role_arn
}

output "task_exec_iam_role_unique_id" {
  description = "Stable and unique string identifying the task execution IAM role"
  value       = module.ecs_cluster.task_exec_iam_role_unique_id
}

output "alb_dns" {
  description = "DNS name of load balancer"
  value       = module.alb.lb_dns_name
}

output "baseurl" {
  description = "The baseUrl to use for the API"
  value       = "http://${module.alb.lb_dns_name}"
}
