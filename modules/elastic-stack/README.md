# Elastic Stack
This is my configuration for configuring the Elastic Stack (https://elastic.co) with:

- Elasticsearch
- Kibana
- Logstash
- Fleet Server (to manage Elastic Agents)

## Variables
You configure these variables in the **./develop/elastic-stack.yaml** configuration file.

### `kibana-encryption-key`
> *Encryption key for Kibana's X-Pack Encrypted Save Objects feature*

- Type: **string**
- Required: True

### `kibana-reporting-encryption-key`
> *Encryption key for Kibana's X-Pack Reporting feature*

- Type: **string**
- Required: true

### `kibana-security-encryption-key`
> *Encryption key for Kibana's X-Pack Security feature*

- Type: **string**
- Required: True

### `kibana-service-token`
> *Service Token to connect to Elasticsearch*

- Type: **string**
- Required: True

#### How to create and use
```sh
$ docker exec --rm -it elasticsearch /bin/bash
$ ./bin/elasticsearch-setup-tokens
# (CTRL-C)

$ docker cp $(docker inspect --format="{{json .}}" elasticsearch | jq -r .Id):/usr/share/elasticsearch/config/users <path to terraform repo>/config/elasticsearch/service_tokens
```

### `elasticsearch-username`
> *The username you configured with Elasticsearch for Logstash*

- Type: **string**
- Required: True

### `elasticsearch-password`
> *The password you configured with Elasticsearch for Logstash*

- Type: **string**
- Required: True

### `logstash-username`
> *The username to access Logstash's HTTP API*

- Type: **string**
- Required: False
- Default: value from `elasticsearch-username`

### `logstash-password`
> *The password to access Logstash's HTTP API*

- Type: **string**
- Required: False
- Default: value from `elasticsearch-password`

#### How to create a user
```sh
$ docker exec --rm -it elasticsearch /bin/bash
$ ./bin/elasticsearch-users useradd <username to use> -r superuser # `-r superuser` is optional, but recommended

# This will copy the required files to reuse.
$ docker cp $(docker inspect --format="{{json .}}" elasticsearch | jq -r .Id):/usr/share/elasticsearch/config/users <path to terraform repo>/config/elasticsearch/users
$ docker cp $(docker inspect --format="{{json .}}" elasticsearch | jq -r .Id):/usr/share/elasticsearch/config/users <path to terraform repo>/config/elasticsearch/users_roles
$ docker cp $(docker inspect --format="{{json .}}" elasticsearch | jq -r .Id):/usr/share/elasticsearch/config/users <path to terraform repo>/config/elasticsearch/elasticsearch.keystore
```
