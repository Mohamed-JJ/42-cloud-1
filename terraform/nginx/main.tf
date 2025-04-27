terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}


# Pulls the image
resource "docker_image" "nginx_image" {
  name = "nginx:latest"
}

# Create a container
resource "docker_container" "nginx_container" {
  image = docker_image.nginx_image.latest
  name  = "nginx_container"
  ports {
    internal = 80
    external = 8080
  }
}