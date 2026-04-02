# Application Load Balancer. Single subnet is sufficient for dev/test.

resource "aws_lb" "main" {
  name               = "acme-bank-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id]

  tags = {
    Name = "acme-bank-${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "services" {
  for_each = toset(local.services)

  name        = "acme-${var.environment}-${each.key}"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 60
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "acme-${var.environment}-${each.key}-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["banking-api"].arn
  }
}

# Path based routing rules for each service

resource "aws_lb_listener_rule" "banking_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["banking-api"].arn
  }

  condition {
    path_pattern {
      values = ["/api/banking/*"]
    }
  }
}

resource "aws_lb_listener_rule" "mobile_banking_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["mobile-banking-api"].arn
  }

  condition {
    path_pattern {
      values = ["/api/mobile/*"]
    }
  }
}

resource "aws_lb_listener_rule" "wealth_management_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["wealth-management-api"].arn
  }

  condition {
    path_pattern {
      values = ["/api/wealth/*"]
    }
  }
}

resource "aws_lb_listener_rule" "compliance_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 400

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["internal-compliance-api"].arn
  }

  condition {
    path_pattern {
      values = ["/api/compliance/*"]
    }
  }
}

resource "aws_lb_listener_rule" "admin_portal" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 500

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["internal-admin-portal"].arn
  }

  condition {
    path_pattern {
      values = ["/admin/*"]
    }
  }
}

resource "aws_lb_listener_rule" "online_banking_portal" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["online-banking-portal"].arn
  }

  condition {
    path_pattern {
      values = ["/portal/*"]
    }
  }
}
