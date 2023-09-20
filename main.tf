terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.21"

    }
  }
}


provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-east-1"
}


resource "aws_vpc" "devops_assessment_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}


resource "aws_subnet" "devops_assessment_public_subnet" {
  count = 2
  vpc_id = aws_vpc.devops_assessment_vpc.id
  cidr_block = "10.0.1.${count.index * 16}/24"
  availability_zone = "us-east-1a"  
  map_public_ip_on_launch = true
}

resource "aws_subnet" "devops_assessment_private_subnet" {
  count = 2
  vpc_id = aws_vpc.devops_assessment_vpc.id
  cidr_block = "10.0.2.${count.index * 16}/24"
  availability_zone = "us-east-1b"  


resource "aws_internet_gateway" "devops_assessment_igw" {
  vpc_id = aws_vpc.devops_assessment_vpc.id
}


resource "aws_vpc_attachment" "devops_assessment_igw_attach" {
  vpc_id = aws_vpc.devops_assessment_vpc.id
  internet_gateway_id = aws_internet_gateway.devops_assessment_igw.id
}

resource "aws_security_group" "devops_assessment_ecs_sg" {
  vpc_id = aws_vpc.devops_assessment_vpc.id
  
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "devops_assessment_cluster" {
  name = "devops-assessment-cluster"
}

resource "aws_lb" "devops_assessment_alb" {
  name               = "devops-assessment-alb"
  internal           = false  
  load_balancer_type = "application"
  subnets            = aws_subnet.devops_assessment_public_subnet[*].id

  enable_deletion_protection = false  
}

resource "aws_lb_target_group" "devops_assessment_target_group" {
  name     = "devops-assessment-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.devops_assessment_vpc.id

  health_check {
    path = "/"
  }
}

resource "aws_ecs_task_definition" "devops_assessment_nginx_task" {
  family                   = "devops-assessment-nginx-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.devops_assessment_ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "nginx-container"
      image = "nginx:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_iam_role" "devops_assessment_ecs_execution_role" {
  name = "devops-assessment-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "devops_assessment_ecs_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.devops_assessment_ecs_execution_role.name
}

resource "aws_ecs_service" "devops_assessment_nginx_service" {
  name            = "devops-assessment-nginx-service"
  cluster         = aws_ecs_cluster.devops_assessment_cluster.id
  task_definition = aws_ecs_task_definition.devops_assessment_nginx_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2  

  network_configuration {
    subnets = aws_subnet.devops_assessment_private_subnet[*].id
    security_groups = [aws_security_group.devops_assessment_ecs_sg.id]
  }
}


resource "aws_s3_bucket" "devops_assessment_bucket" {
  bucket = "devops-assessment-nginx-bucket"  
  acl    = "private"
}

resource "aws_s3_bucket_policy" "devops_assessment_bucket_policy" {
  bucket = aws_s3_bucket.devops_assessment_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.devops_assessment_bucket.arn}/*",
          aws_s3_bucket.devops_assessment_bucket.arn,
        ],
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
