terraform {
  required_providers {
    docker = {
      version = "2.22.0"
      source  = "kreuzwerker/docker"
    }
  }
}

locals {
  data = yamldecode(file("./develop/redis.yaml"))
}

resource "docker_image" "redis" {
  keep_locally = true
  name         = "bitnami/redis:7.0.4"
}

resource "docker_container" "redis" {
  networks_advanced {
    name = var.docker_network
  }

  ports {
    internal = 6379
    external = 6379
    protocol = "tcp"
  }

  volumes {
    container_path = "/bitnami/redis"
    host_path      = "/mnt/storage/data/.data/redis"
  }

  env = [
    "REDIS_PASSWORD=${local.data["password"]}"
  ]

  restart = "always"
  image   = docker_image.redis.latest
  name    = "redis"
}
