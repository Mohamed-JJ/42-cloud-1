terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

# Pulls the image
resource "docker_image" "wordpress_image" {
  name = "wordpress:fpm"
}


# Create a container
resource "docker_container" "wordpress_container" {
  image = docker_image.wordpress.fpm
  name  = "wordpress"
}
