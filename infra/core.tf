# Security Group
resource "aws_security_group" "svc" {
  name   = "hands-on-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
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

# ECR
resource "aws_ecr_repository" "app" {
  name         = "hands-on-app"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
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
