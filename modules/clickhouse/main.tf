terraform {
  required_providers {
    docker = {
      version = "2.22.0"
      source  = "kreuzwerker/docker"
    }
  }
}

locals {
  data = yamldecode(file("./develop/clickhouse.yaml"))
}

resource "docker_image" "clickhouse" {
  keep_locally = true
  name         = "clickhouse/clickhouse-server:22.6.9.11-alpine"
}

resource "docker_container" "clickhouse" {
  networks_advanced {
    name = var.docker_network
  }

  # http interface (might be required, idk?)
  ports {
    internal = 8123
    external = 8123
  }

  # tcp interface for clickhouse clients
  ports {
    internal = 9000
    external = 9000
  }

  volumes {
    container_path = "/var/log/clickhouse-server"
    host_path      = "/mnt/storage/data/.data/clickhouse/logs"
  }

  volumes {
    container_path = "/var/lib/clickhouse"
    host_path      = "/mnt/storage/data/.data/clickhouse/data"
  }

  # server configuration
  volumes {
    container_path = "/etc/clickhouse-server/config.d/noel.xml"
    host_path      = "/mnt/storage/data/config/clickhouse/server.xml"
  }

  # users configuration
  volumes {
    container_path = "/etc/clickhouse-server/users.d/noel.xml"
    host_path      = "/mnt/storage/data/config/clickhouse/users.xml"
  }

  capabilities {
    add = ["SYS_NICE", "NET_ADMIN", "IPC_LOCK"]
  }

  ulimit {
    name = "memlock"
    hard = 262144
    soft = 262144
  }

  env = [
    "CLICKHOUSE_PASSWORD=${local.data["clickhouse-password"]}",
    "CLICKHOUSE_USER=${local.data["clickhouse-username"]}"
  ]

  restart = "always"
  image   = docker_image.clickhouse.latest
  name    = "clickhouse"
}
