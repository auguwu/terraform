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

variable "kibana_savedobjects_encryptionkey" {
  description = "The encryption key for Kibana Saved Objects."
  sensitive   = true
  type        = string
}

variable "kibana_reporting_encryptionkey" {
  description = "The encryption key for Kibana X-Pack Reporting."
  sensitive   = true
  type        = string
}

variable "kibana_security_encryptionkey" {
  description = "The encryption key for Kibana X-Pack Security."
  sensitive   = true
  type        = string
}

variable "kibana_service_token" {
  description = "Service token for Kibana"
  sensitive   = true
  type        = string
}

variable "logstash_username" {
  description = "Username for Logstash's API."
  type        = string
}

variable "logstash_password" {
  description = "Password for Logstash's API."
  sensitive   = true
  type        = string
}

variable "redis_password" {
  description = "Password for connecting to Redis."
  sensitive   = true
  type        = string
}

variable "keep_docker_images" {
  description = "If we should keep the Docker Images locally? This is recommended to be set to `true` since the Elastic Stack's images are quite large."
  default     = true
  type        = bool
}

variable "postgres_password" {
  description = "The password for the `postgres` user."
  sensitive   = true
  default     = "postgres"
  type        = string
}

data "docker_network" "fluff" {
  name   = "fluff"
}

resource "docker_image" "elasticsearch" {
  keep_locally = var.keep_docker_images
  name         = "docker.elastic.co/elasticsearch/elasticsearch:8.3.3"
}

resource "docker_image" "kibana" {
  keep_locally = var.keep_docker_images
  name         = "docker.elastic.co/kibana/kibana:8.3.3"
}

resource "docker_image" "logstash" {
  keep_locally = var.keep_docker_images
  name         = "docker.elastic.co/logstash/logstash:8.3.3"
}

resource "docker_image" "postgresql" {
  keep_locally = var.keep_docker_images
  name         = "bitnami/postgresql:14.4.0"
}

resource "docker_image" "redis" {
  keep_locally = var.keep_docker_images
  name         = "bitnami/redis:7.0.4"
}

resource "docker_image" "zookeeper" {
  keep_locally = var.keep_docker_images
  name         = "bitnami/zookeeper:3.7.1"
}

resource "docker_image" "kafka" {
  keep_locally = var.keep_docker_images
  name         = "bitnami/kafka:3.2.1"
}

resource "docker_image" "cassandra" {
  keep_locally = var.keep_docker_images
  name         = "cassandra:4.0.5"
}

resource "docker_container" "elasticsearch" {
  networks_advanced {
    name = data.docker_network.fluff.name
  }

  ports {
    internal = 9200
    external = 9200
    protocol = "tcp"
  }

  volumes {
    container_path = "/usr/share/elasticsearch/data"
    host_path = "/mnt/storage/data/.data/elasticsearch"
  }

  mounts {
    target = "/usr/share/elasticsearch/config"
    type = "bind"
    source = "/mnt/storage/data/config/elasticsearch"
  }

  env = [
    "discovery.type=single-node",
    "ES_JAVA_OPTS=-Xms1024m -Xmx4096m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8"
  ]

  restart = "always"
  image = docker_image.elasticsearch.latest
  name = "elasticsearch"
}

resource "docker_container" "kibana" {
  networks_advanced {
    name = data.docker_network.fluff.name
  }

  ports {
    internal = 5601
    external = 5601
    protocol = "tcp"
  }

  volumes {
    container_path = "/usr/share/kibana/config/kibana.yml"
    host_path = "/mnt/storage/data/config/kibana/kibana.yml"
  }

  env = [
    "KIBANA_REPORTING_ENCRYPTION_KEY=${var.kibana_reporting_encryptionkey}",
    "KIBANA_SECURITY_ENCRYPTION_KEY=${var.kibana_security_encryptionkey}",
    "KIBANA_ENCRYPTION_KEY=${var.kibana_savedobjects_encryptionkey}",
    "KIBANA_SERVICE_TOKEN=${var.kibana_service_token}",
    "ELASTICSEARCH_HOSTS=http://elasticsearch:9200"
  ]

  depends_on = [
    docker_container.elasticsearch
  ]

  restart = "always"
  image = docker_image.kibana.latest
  name = "kibana"
}

resource "docker_container" "logstash" {
  networks_advanced {
    name = data.docker_network.fluff.name
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
    host_path = "/mnt/storage/data/config/logstash/pipeline.conf"
  }

  volumes {
    container_path = "/usr/share/logstash/config/logstash.yml"
    host_path = "/mnt/storage/data/config/logstash/logstash.yml"
  }

  env = [
    "LOGSTASH_USERNAME=${var.logstash_username}",
    "LOGSTASH_PASSWORD=${var.logstash_password}"
  ]

  depends_on = [
    docker_container.elasticsearch
  ]

  restart = "always"
  image = docker_image.logstash.latest
  name = "logstash"
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

  volumes {
    container_path = "/bitnami/redis"
    host_path = "/mnt/storage/data/.data/redis"
  }

  env = [
    "REDIS_PASSWORD=${var.redis_password}"
  ]

  restart = "always"
  image = docker_image.redis.latest
  name = "redis"
}

resource "docker_container" "kafka" {
  networks_advanced {
    name = data.docker_network.fluff.name
  }

  ports {
    external = 9092
    internal = 9092
  }

  volumes {
    container_path = "/bitnami/kafka"
    host_path = "/mnt/storage/data/.data/kafka"
  }

  env = [
    "ALLOW_PLAINTEXT_LISTENER=yes",
    "KAFKA_BROKER_ID=1",
    "KAFKA_CFG_LISTENERS=PLAINTEXT://:9092",
    "KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://127.0.0.1:9092",
    "KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181"
  ]

  depends_on = [
    docker_container.zookeeper
  ]

  restart = "always"
  image = docker_image.kafka.latest
  name = "kafka"
}

resource "docker_container" "zookeeper" {
  networks_advanced {
    name = data.docker_network.fluff.name
  }

  ports {
    external = 2181
    internal = 2181
  }

  env = [
    "ALLOW_ANONYMOUS_LOGIN=yes"
  ]

  volumes {
    container_path = "/data/zookeeper"
    host_path = "/mnt/storage/data/.data/zookeeper"
  }

  volumes {
    container_path = "/opt/bitnami/zookeeper/conf/zoo.cfg"
    host_path = "/mnt/storage/data/config/zookeeper/zookeeper.conf"
    read_only = true
  }

  restart = "always"
  image = docker_image.zookeeper.latest
  name = "zookeeper"
}

resource "docker_container" "postgres" {
  networks_advanced {
    name = data.docker_network.fluff.name
  }

  ports {
    external = 5432
    internal = 5432
  }

  env = [
    "POSTGRESQL_POSTGRES_PASSWORD=noeliscutieuwu",
    "POSTGRESQL_INITDB_WALDIR=/bitnami/waldir",
    "POSTGRESQL_PASSWORD=noeliscutieuwu",
    "POSTGRESQL_WAL_LEVEL=logical"
  ]

  volumes {
    container_path = "/bitnami/postgresql"
    host_path = "/var/lib/docker/volumes/postgres/_data"
  }

  restart = "always"
  image = docker_image.postgresql.latest
  name = "postgres"
}

resource "docker_container" "cassandra" {
  networks_advanced {
    name = data.docker_network.fluff.name
  }

  ports {
    internal = 7000
    external = 7000
  }

  ports {
    external = 9042
    internal = 9042
  }

  volumes {
    container_path = "/var/lib/cassandra"
    host_path = "/mnt/storage/data/.data/cassandra"
  }

  env = [
    "CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch",
    "CASSANDRA_DC=noel-us-west1",
    "CASSANDRA_RACK=noel-cassandra-rack-0",
    "CASSANDRA_CLUSTER_NAME=Noel Cluster",
    "JVM_OPTS=-Xms1024m -Xmx4096m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8"
  ]

  restart = "always"
  image = docker_image.cassandra.latest
  name = "cassandra"
}
