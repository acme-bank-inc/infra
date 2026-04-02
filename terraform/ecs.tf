# ECS Cluster with Fargate. Minimal resource allocation per service.

locals {
  services = [
    "banking-api",
    "mobile-banking-api",
    "wealth-management-api",
    "online-banking-portal",
    "internal-compliance-api",
    "internal-admin-portal",
  ]
}

resource "aws_ecs_cluster" "main" {
  name = "acme-bank-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "acme-bank-${var.environment}-cluster"
  }
}

# IAM role for ECS task execution (pulling images, writing logs)

resource "aws_iam_role" "ecs_execution" {
  name = "acme-bank-${var.environment}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch log group for all services

resource "aws_cloudwatch_log_group" "services" {
  name              = "/ecs/acme-bank-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "acme-bank-${var.environment}-logs"
  }
}

# Task definitions and services for each microservice

resource "aws_ecs_task_definition" "services" {
  for_each = toset(local.services)

  family                   = "acme-${var.environment}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = "ghcr.io/acme-bank-inc/${each.key}:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.services.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = each.key
        }
      }
      environment = [
        {
          name  = "PORT"
          value = tostring(var.container_port)
        },
        {
          name  = "ENV"
          value = var.environment
        }
      ]
    }
  ])

  tags = {
    Name = "acme-${var.environment}-${each.key}-task"
  }
}

resource "aws_ecs_service" "services" {
  for_each = toset(local.services)

  name            = each.key
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.services[each.key].arn
    container_name   = each.key
    container_port   = var.container_port
  }

  tags = {
    Name = "acme-${var.environment}-${each.key}-svc"
  }
}
