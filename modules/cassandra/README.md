# Apache Cassandra
This is the configuration for Apache Cassandra for [charted-server](https://charts.noelware.org). **charted-server** uses Apache Cassandra to store audit log events (user, repo, and organization) and webhook events to analyze what data is being transferred in/out from.

## Variables
You configure these variables in the **./develop/cassandra.yaml** configuration file.

### `cassandra-username`
> *The username to enable Cassandra authentication*

- Type: **string**
- Requried: True

### `cassandra-password`
> *The password to enable Cassandra authentication*

- Type: **string**
- Requried: True
