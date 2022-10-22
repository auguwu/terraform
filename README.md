# 🛩️ Noel's Terraform Configuration
> *Terraform configuration for development of my projects.*

This is a repository of the Terraform configuration for applying the software I use when I develop my projects. I used to use Docker Compose but as the list grows, the more it was hard to maintain and to fix maintenance on. It uses the Docker [Terraform provider](https://github.com/kreuzwerker/terraform-provider-docker).

This is also probably going to be the foundation that [Noelware's Infrastructure](https://noelware.org) will extend from (in a closed repository).

## Docker Images
- Elasticsearch, Kibana, Logstash, Elastic Agent [v8.4.1](https://www.docker.elastic.co)
- ClickHouse [v22.6.9.11](https://hub.docker.com/layers/clickhouse/clickhouse-server/22.6.9.11-alpine/images/sha256-1209d9a2a345cbbd6a9c6f02d4b0bde914e221d28c684091df2e539881d8c064?context=explore)
- ZooKeeper [v3.8.0](https://hub.docker.com/layers/bitnami/zookeeper/3.8.0/images/sha256-92969db064eeaa54bb4eba7759e67af8daca854c5b818277f6603c99a1f37626?context=explore)
- PostgreSQL [v14.5](https://hub.docker.com/layers/bitnami/postgresql/14.5.0/images/sha256-c971528f2197e76bb7f7bcd09545b83dd8fec9057d4e51b334ae589b0398ed08?context=explore)
- Cassandra [v4.0.6](https://hub.docker.com/layers/bitnami/cassandra/4.0.6/images/sha256-d7c96c845b50ebfe9bcd45b139d532f96f32360391dc39353edf4e3f96a26520?context=explore)
- Kafka [v3.3.1](https://hub.docker.com/layers/bitnami/kafka/3.3.1/images/sha256-7ba079a216c755dd0f92c9fbcea7c9cf58ba59c50b7fcaefc92ee5695d48e002?context=explore)

## Scripts
### ./scripts/install.sh
This script will install the `./scripts/apply.sh` and `./scripts/destroy.sh` scripts into the user's bin directory (`/usr/local/bin`) as `terraform-apply` and `terraform-destroy`.

### ./scripts/apply.sh
This script will run the `terraform apply` command.

#### Environment Variables
| Name                   | Description                                                  | Examples                        |
| ---------------------- | ------------------------------------------------------------ | ------------------------------- |
| `BOOTSTRAP_CHECKS`     | If the apply script should run any bootstrap checks or not.  | `BOOTSTRAP_CHECKS=yes`          |
| `TERRAFORM_ARGS`       | List of arguments to append to the `terraform plan` command. | `TERRAFORM_ARGS=-auto-approve`  |
| `TERRAFORM_AUTO_APPLY` | Appends the `-auto-approve` argument to `terraform plan`     | `TERRAFORM_AUTO_APPLY=yes`      |

### ./scripts/destroy.sh
This script will run the `terraform destroy` command. This script uses the same [environment variables](#environment-variables).

## License
This won't have a LICENSE attached to it, so you can use this for yourself if you want to. :)
