terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.20.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

data "docker_network" "fluff" {
  name   = "fluff"
}

resource "docker_image" "elasticsearch" {
  keep_locally = false
  name         = "docker.elastic.co/elasticsearch/elasticsearch:8.3.3"
}

resource "docker_image" "kibana" {
  keep_locally = false
  name         = "docker.elastic.co/kibana/kibana:8.3.3"
}

resource "docker_image" "logstash" {
  keep_locally = false
  name         = "docker.elastic.co/logstash/logstash:8.3.3"
}

resource "docker_image" "postgresql" {
  keep_locally = false
  name         = "bitnami/postgresql:14.4.0"
}

resource "docker_image" "redis" {
  keep_locally = false
  name         = "bitnami/redis:7.0.4"
}

resource "docker_image" "zookeeper" {
  keep_locally = false
  name         = "bitnami/zookeeper:3.7.1"
}

resource "docker_image" "kafka" {
  keep_locally = false
  name         = "bitnami/kafka:3.2.1"
}

resource "docker_image" "cassandra" {
  keep_locally = false
  name         = "bitnami/cassandra:4.0.5"
}

resource "docker_container" "redis" {
  networks_advanced {
    name = data.docker_network.fluff.name
  }

  ports {
    internal = 6379
    external = 6379
    protocol = "tcp"
  }

  env = [
    "REDIS_PASSWORD=noeliscutieuwu"
  ]

  restart = "always"
  image = docker_image.redis.latest
  name = "redis"
}
