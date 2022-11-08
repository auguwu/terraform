terraform {
  required_providers {
    docker = {
      version = "2.22.0"
      source  = "kreuzwerker/docker"
    }
  }
}

locals {
  data = yamldecode(file("./develop/elastic-stack.yaml"))
}

resource "docker_image" "elasticsearch" {
  keep_locally = true
  name         = "docker.elastic.co/elasticsearch/elasticsearch:8.4.3"
}

resource "docker_image" "kibana" {
  keep_locally = true
  name         = "docker.elastic.co/kibana/kibana:8.4.3"
}

resource "docker_image" "logstash" {
  keep_locally = true
  name         = "docker.elastic.co/logstash/logstash:8.4.3"
}

resource "docker_image" "elastic_agent" {
  keep_locally = true
  name         = "docker.elastic.co/beats/elastic-agent:8.4.3"
}

resource "docker_container" "elasticsearch" {
  networks_advanced {
    name = var.docker_network
  }

  ports {
    internal = 9200
    external = 9200
    protocol = "tcp"
  }

  volumes {
    container_path = "/usr/share/elasticsearch/data"
    host_path      = "/mnt/storage/data/.data/elasticsearch"
  }

  mounts {
    source = "/mnt/storage/data/config/elasticsearch"
    target = "/usr/share/elasticsearch/config"
    type   = "bind"
  }

  env = [
    "discovery.type=single-node",
    "ES_JAVA_OPTS=-Xms1024m -Xmx4096m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8"
  ]

  restart = "always"
  image   = docker_image.elasticsearch.latest
  name    = "elasticsearch"
}

resource "docker_container" "kibana" {
  networks_advanced {
    name = var.docker_network
  }

  ports {
    external = 5601
    internal = 5601
    protocol = "tcp"
  }

  volumes {
    container_path = "/usr/share/kibana/config/kibana.yml"
    host_path      = "/mnt/storage/data/config/kibana/kibana.yml"
  }

  env = [
    "KIBANA_REPORTING_ENCRYPTION_KEY=${local.data["kibana-reporting-encryption-key"]}",
    "KIBANA_SECURITY_ENCRYPTION_KEY=${local.data["kibana-security-encryption-key"]}",
    "KIBANA_ENCRYPTION_KEY=${local.data["kibana-encryption-key"]}",
    "KIBANA_SERVICE_TOKEN=${local.data["kibana-service-token"]}",
    "ELASTICSEARCH_HOSTS=http://elasticsearch:9200"
  ]

  depends_on = [
    docker_container.elasticsearch
  ]

  restart = "always"
  image   = docker_image.kibana.latest
  name    = "kibana"
}

resource "docker_container" "logstash" {
  networks_advanced {
    name = var.docker_network
  }

  ports {
    internal = 9600
    external = 9600
    protocol = "tcp"
  }

  ports {
    internal = 4040
    external = 4040
    protocol = "tcp"
  }

  volumes {
    container_path = "/usr/share/logstash/pipeline/pipeline.conf"
    host_path      = "/mnt/storage/data/config/logstash/pipeline.conf"
  }

  volumes {
    container_path = "/usr/share/logstash/config/logstash.yml"
    host_path      = "/mnt/storage/data/config/logstash/logstash.yml"
  }

  env = [
    "ELASTICSEARCH_PASSWORD=${local.data["elasticsearch-password"]}",
    "ELASTICSEARCH_USERNAME=${local.data["elasticsearch-username"]}",
    "LOGSTASH_PASSWORD=${try(local.data["logstash-password"], "") == "" ? local.data["elasticsearch-password"] : local.data["logstash-password"]}",
    "LOGSTASH_USERNAME=${try(local.data["logstash-username"], "") == "" ? local.data["elasticsearch-username"] : local.data["logstash-username"]}"
  ]

  depends_on = [
    docker_container.elasticsearch
  ]

  restart = "always"
  image   = docker_image.logstash.latest
  name    = "logstash"
}

resource "docker_container" "fleet_server" {
  networks_advanced {
    name = var.docker_network
  }

  ports {
    external = 8220
    internal = 8220
    protocol = "tcp"
  }

  env = [
    "FLEET_SERVER_ELASTICSEARCH_HOST=http://elasticsearch:9200",
    "FLEET_SERVER_SERVICE_TOKEN=${local.data["fleet-server-service-token"]}",
    "FLEET_SERVER_ENABLE=true",
    "KIBANA_FLEET_SETUP=1",
    "KIBANA_HOST=http://kibana:5601",
    "FLEET_URL=https://0.0.0.0:8220",
  ]

  restart = "always"
  image   = docker_image.elastic_agent.latest
  name    = "fleet_server"
}

resource "docker_container" "elastic_agent" {
  networks_advanced {
    name = var.docker_network
  }

  # Each Elastic Agent runs APM server, so this is required to be used!
  ports {
    external = 8200
    internal = 8200
    protocol = "tcp"
  }

  env = [
    "FLEET_ENROLLMENT_TOKEN=${local.data["elastic-agent-enrollment-token"]}",
    "FLEET_URL=https://fleet_server:8220",
  ]

  restart = "always"
  image   = docker_image.elastic_agent.latest
  name    = "elastic_agent_1"
}
