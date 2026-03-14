# Cgent - Containerized Nezha-agent

fork from [cgent](https://github.com/yosebyte/cgent)

## Configuration Options

[See Official Document](https://nezha.wiki/en_US/configuration/agent.html#options)
You can transfer offical config variable to Docker Environment:

| Config Variable       | Environment Variable        | Default                     |
| --------------------- | --------------------------- | --------------------------- |
| `server`              | `NEZHA_SERVER`              | _required_                  |
| `client_secret`       | `NEZHA_CLIENT_SECRET`       | _required_                  |
| `uuid`                | `NEZHA_UUID`                | _fixed by your mac address_ |
| `debug`               | `NEZHA_DEBUG`               | `true`                      |
| `tls`                 | `NEZHA_TLS`                 | `false`                     |
| `disable_auto_update` | `NEZHA_DISABLE_AUTO_UPDATE` | `false`                     |
| `var`                 | `NEZHA_VAR`                 |                             |

## Important Notes

- Must use `network_mode=host`
- When you don't set `NEZHA_UUID` env, uuid will be generated automatically base on host machine network device mac address.
- Find your `SECRET`, `SERVER`, and TLS settings in your Nezha dashboard configuration
