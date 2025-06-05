# Terraform configuration with intentional misconfigurations for Trivy testing

terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# S3 bucket with public read access (misconfiguration)
resource "aws_s3_bucket" "example" {
  bucket = "trivy-test-bucket-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Public read ACL - security issue
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}

# No encryption enabled - security issue
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# EC2 instance without encryption
resource "aws_instance" "web" {
  ami           = "ami-0c94855ba95b798c7"
  instance_type = "t2.micro"

  # No encryption for root volume
  root_block_device {
    volume_type = "gp2"
    volume_size = 20
    encrypted   = false  # This should be true
  }

  # Security group allows all traffic
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  # No IMDSv2 enforcement
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"  # Should be "required"
  }

  tags = {
    Name = "trivy-test-instance"
  }
}

# Security group allowing all inbound traffic - major security issue
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    description = "All traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Should be restricted
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS instance without encryption
resource "aws_db_instance" "example" {
  identifier     = "trivy-test-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_encrypted = false  # Should be true
  
  db_name  = "testdb"
  username = "admin"
  password = "password123"  # Hardcoded password - security issue
  
  skip_final_snapshot = true
  
  # No backup retention
  backup_retention_period = 0  # Should be > 0
  
  # Public access enabled
  publicly_accessible = true  # Should be false
}

# CloudWatch log group without encryption
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/trivy-test"
  retention_in_days = 7
  
  # No KMS encryption
  # kms_key_id = aws_kms_key.example.arn  # Should be enabled
}

# ALB without access logging
resource "aws_lb" "example" {
  name               = "trivy-test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  enable_deletion_protection = false

  # No access logs configured
  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }
}

# VPC without flow logs
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "trivy-test-vpc"
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main IGW"
  }
}
