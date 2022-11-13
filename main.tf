terraform {
  required_providers {
    docker = {
      version = "2.22.0"
      source  = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

data "docker_network" "fluff" {
  name = "fluff"
}

module "clickhouse" {
  source         = "./modules/clickhouse"
  docker_network = data.docker_network.fluff.name

  providers = {
    docker = docker
  }
}

module "elastic_stack" {
  source         = "./modules/elastic-stack"
  docker_network = data.docker_network.fluff.name

  providers = {
    docker = docker
  }
}

module "postgres" {
  source         = "./modules/postgres"
  docker_network = data.docker_network.fluff.name

  providers = {
    docker = docker
  }
}

module "redis" {
  source         = "./modules/redis"
  docker_network = data.docker_network.fluff.name

  providers = {
    docker = docker
  }
}
