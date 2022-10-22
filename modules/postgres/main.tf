terraform {
  required_providers {
    docker = {
      version = "2.22.0"
      source  = "kreuzwerker/docker"
    }
  }
}

locals {
  data = yamldecode(file("./develop/postgres.yaml"))
}

resource "docker_image" "postgres" {
  keep_locally = true
  name         = "bitnami/postgresql:14.5.0"
}

resource "docker_container" "postgres" {
  networks_advanced {
    name = var.docker_network
  }

  ports {
    internal = 5432
    external = 5432
    protocol = "tcp"
  }

  volumes {
    container_path = "/bitnami/postgresql"
    host_path      = "/mnt/storage/data/.data/postgres"
  }

  env = [
    "POSTGRESQL_LOG_TIMEZONE=America/Phoenix",
    "POSTGRESQL_TIMEZONE=America/Phoenix",
    "POSTGRESQL_PASSWORD=${local.data["password"]}",
    "POSTGRESQL_USERNAME=${local.data["username"]}"
  ]

  restart = "always"
  image   = docker_image.postgres.latest
  name    = "postgres"
}
