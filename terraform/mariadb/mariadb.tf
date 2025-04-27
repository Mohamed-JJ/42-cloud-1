terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}




# Pulls the image
resource "docker_image" "mariadb_image" {
  name = "mariadb"
}

# Create a container
resource "docker_container" "mariadb_container" {
  image = docker_image.mariadb
  name  = "database"
}