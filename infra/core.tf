# Security Group
resource "aws_security_group" "alb" {
  name = "hands-on-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "svc" {
  name   = "hands-on-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load balancer
resource "aws_lb" "app" {
  name = "hands-on-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = module.vpc.public_subnets
}

resource "aws_lb_target_group" "app" {
  name = "hands-on-app-tg"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = module.vpc.vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    healthy_threshold = 3
    unhealthy_threshold = 3
    interval = 30
    timeout = 5
    matcher = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = aws_acm_certificate.app.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  depends_on = [ aws_acm_certificate_validation.app ]
}

# ECR
resource "aws_ecr_repository" "app" {
  name         = "hands-on-app"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_route53_zone" "root" {
  name = var.domain_name
}

# ACM
resource "aws_acm_certificate" "app" {
  domain_name = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  certificate_domain_validation_records = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      type = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
}

resource "aws_route53_record" "app_validation" {
  for_each = local.certificate_domain_validation_records

  zone_id = aws_route53_zone.root.zone_id
  name = each.value.name
  type = each.value.type
  records = [each.value.record]
  ttl = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.app_validation : record.fqdn]
  
}

resource "aws_route53_record" "app_aliase_a" {
  zone_id = aws_route53_zone.root.zone_id
  name = var.domain_name
  type = "A"
  alias {
    name = aws_lb.app.dns_name
    zone_id = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

# Cloudwatch Logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/hands-on"
  retention_in_days = 7
}

# IAM タスク実行ロール
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-hands-on"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
