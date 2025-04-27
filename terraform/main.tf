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
  host = "unix:///var/run/docker.sock"
}

provider "aws" {
  region = var.region
}

# resource "aws_instance" "cloud-1" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"

#   tags = {
#     Name = "cloud-1"
#   }
# }

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