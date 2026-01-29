terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# --- 1. ECR Repositories ---
resource "aws_ecr_repository" "app_repo" {
  name         = "clo835-assignment1-app"
  force_delete = true
}

resource "aws_ecr_repository" "db_repo" {
  name         = "clo835-assignment1-db"
  force_delete = true
}

# --- 2. Security Group ---
resource "aws_security_group" "assignment_sg" {
  name        = "assignment1-sg"
  description = "Allow SSH, App Ports, and Ping"

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App Instance 1 (Blue)
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App Instance 2 (Pink)
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App Instance 3 (Lime)
  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP (Ping)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- 3. EC2 Instance ---
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  
  # *** VOCLAB REQUIREMENT ***
  iam_instance_profile = "LabInstanceProfile"
  
  security_groups = [aws_security_group.assignment_sg.name]
  key_name = "vockey"

  tags = {
    Name = "CLO835-Assignment1-Student"
  }
}

# --- 4. Outputs ---
output "ecr_app_repo_url" {
  value = aws_ecr_repository.app_repo.repository_url
}

output "ecr_db_repo_url" {
  value = aws_ecr_repository.db_repo.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
}
