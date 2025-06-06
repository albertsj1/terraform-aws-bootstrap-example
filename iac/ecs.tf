module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.2.0"

  cluster_name = "${var.app_name}-ecs"

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = var.ecs_tags
}

# ECS Service
module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.0"

  name          = "${var.app_name}-ecs-service"
  cluster_arn   = module.ecs_cluster.arn
  desired_count = 1
  launch_type   = "FARGATE"

  cpu    = 256
  memory = 512

  container_definitions = {
    (var.app_name) = {
      cpu       = 256
      memory    = 512
      essential = true
      image     = local.ecr_image
      port_mappings = [
        {
          name          = var.app_name
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      health_check = {
        command = [
          "CMD-SHELL",
          "wget --no-verbose --tries=1 --spider http://127.0.0.1:8000/health 2>/dev/null|| exit 1"
        ],
        interval     = 30,
        retries      = 3,
        timeout      = 5
        start_period = 300
      }
    }
  }

  subnet_ids            = data.terraform_remote_state.infra.outputs.private_subnets
  create_security_group = false
  security_group_ids    = [aws_security_group.ecs-service.id]

  autoscaling_min_capacity      = var.ecs_autoscaling_min_capacity
  autoscaling_max_capacity      = var.ecs_autoscaling_max_capacity
  autoscaling_policies          = var.ecs_autoscaling_policies
  autoscaling_scheduled_actions = var.ecs_autoscaling_scheduled_actions

  load_balancer = {
    service = {
      target_group_arn = element(module.alb.target_group_arns, 0)
      container_name   = var.app_name
      container_port   = 8000
    }
  }

  tags = var.ecs_tags
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.app_name}-alb-sg"
  description = "${var.app_name}-alb security group"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = var.alb_allowed_list

  egress_with_source_security_group_id = [{
    description              = "Allow connection to service"
    from_port                = 8000
    to_port                  = 8000
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.ecs-service.id
  }]

  tags = var.alb_tags
}

# ALB
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name                  = "${var.app_name}-alb"
  load_balancer_type    = "application"
  vpc_id                = data.terraform_remote_state.infra.outputs.vpc_id
  subnets               = data.terraform_remote_state.infra.outputs.public_subnets
  security_groups       = [module.alb_sg.security_group_id]
  create_security_group = false

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name             = "${var.app_name}-tg"
      backend_protocol = "HTTP"
      backend_port     = 8000
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/health"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }
    },
  ]

  tags = var.alb_tags
}

resource "aws_security_group" "ecs-service" {
  name        = "${var.app_name}-ecs-service"
  description = "Security group for ${var.app_name}-ecs service"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [module.alb_sg.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.app_name}-ecs-service" }
}
