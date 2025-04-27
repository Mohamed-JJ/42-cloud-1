data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

variable "region" {
  type = string
  default = "me-south-1"
}

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.12.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "docker" {
  host = var.docker_target == "local" ? "unix:///var/run/docker.sock" : "tcp://${aws_instance.cloud-1.public_ip}:2375/"
}

provider "aws" {
  region = var.region
}

variable "docker_target" {
  description = "Where to deploy Docker containers: 'local' or 'remote'"
  type        = string
  default     = "local"
}

resource "aws_instance" "cloud-1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              sudo sed -i 's|ExecStart=.*|ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375|' /lib/systemd/system/docker.service
              sudo systemctl daemon-reexec
              sudo systemctl restart docker
            EOF
  tags = {
    Name = "cloud-1"
  }
}
resource "aws_security_group" "docker_sg" {
  name   = "docker-sg"

  ingress {
    from_port   = 2375
    to_port     = 2375
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.cloud-1.public_ip}/32"] # restrict to your IP, NOT 0.0.0.0/0!!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


module "nginx" {
  source = "./nginx" # path to your submodule folder
  # (optional) Pass variables to the module if needed
}

module "wordpress" {
  source = "./wordpress" # path to your submodule folder
  # (optional) Pass variables to the module if needed
}

module "mariadb" {
  source = "./mariadb" # path to your submodule folder
  # (optional) Pass variables to the module if needed
}

output "docker_host_used" {
  value = var.docker_target == "local" ? "Local Docker" : "Remote Docker on EC2 ${aws_instance.cloud-1.public_ip}"
}