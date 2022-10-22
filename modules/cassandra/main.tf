terraform {
  required_providers {
    docker = {
      version = "2.22.0"
      source  = "kreuzwerker/docker"
    }
  }
}

locals {
  data = yamldecode(file("./develop/cassandra.yaml"))
}

resource "docker_image" "cassandra" {
  keep_locally = true
  name         = "bitnami/cassandra:4.0.6"
}

resource "docker_container" "cassandra" {
  networks_advanced {
    name = var.docker_network
  }

  ports {
    internal = 7000
    external = 7000
  }

  ports {
    internal = 9042
    external = 9042
  }

  volumes {
    container_path = "/bitnami/cassandra"
    host_path      = "/mnt/storage/data/.data/cassandra"
  }

  env = [
    "CASSANDRA_USER=${local.data.username}",
    "CASSANDRA_PASSWORD_SEEDER=yes",
    "CASSANDRA_PASSWORD=${local.data.password}",
    "CASSANDRA_CLUSTER_NAME=noel-cluster-0",
    "CASSANDRA_DATACENTER=noel-us-west-1",
    "CASSANDRA_RACK=noel-us-west-1-0",
    "JVM_OPTS=-Xms1024m -Xmx4096m -Dfile.encoding=UTF-8"
  ]

  restart = "always"
  image   = docker_image.cassandra.latest
  name    = "cassandra"
}
