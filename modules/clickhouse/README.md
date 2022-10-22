# ClickHouse
**ClickHouse** is used through out Noelware's services. [Noelware Telemetry](https://telemetry.noelware.org) and [Noelware Analytics](https://analytics.noelware.org) uses ClickHouse to store analytical data so we can preview it at any date.

## Variables
You configure these variables in the **./develop/clickhouse.yaml** configuration file.

### `clickhouse-username`
> *The username to setup ClickHouse authentication.*

- Type: **string**
- Required: True

### `clickhouse-password`
> *The password to setup ClickHouse authentication.*

- Type: **string**
- Required: True
