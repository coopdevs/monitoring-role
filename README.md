# Monitoring Role [![Ansible Galaxy](https://img.shields.io/badge/Ansible_Galaxy-coopdevs/monitoring__role-green?link=https%3A%2F%2Fgalaxy.ansible.com%2Fcoopdevs%2Fmonitoring_role)](https://galaxy.ansible.com/coopdevs/monitoring_role)

An Ansible role for maintaining monitoring tools of the Grafana ecosystem.

Uses docker to install Prometheus and Loki exporters:
* `nodeexporter`: prometheus exporter that collects general data about the state of a host.
* `postgresexporter`: prometheus exporter that monitors the state of Postgreql server
* `promtail`: the main exporter for Loki, a logs server similar to Prometheus and compatible with Grafana.

This role supports some applications with their default logging format:
* [Odoo12](https://github.com/coopdevs/odoo-role)
* [Coopdevs backups](https://github.com/coopdevs/backups-role/)
* [`auth.log`](templates/promtail-config-apps/auth.j2)

Besides, it supports a [custom exporter](https://github.com/stfsy/prometheus-what-active-users-exporter) that exposes the active users in the system.

It can also run [odoo-instance-api](https://pypi.org/project/odoo-instance-api/) as an on-demand diagnostics API (it is not a Prometheus exporter).

## Using this role

### Public variables

**NodeExporter**
```yaml
# defaults/main.yaml
monitoring_nexporter_enabled: true
monitoring_nexporter_host: 127.0.0.1
monitoring_nexporter_port: 9100
monitoring_nexporter_docker_bind: "127.0.0.1:127.0.0.1:9100"
monitoring_nexporter_container_name: nexporter
monitoring_nexporter_image_version: latest
```

**PostgresqlExporter**
```yaml
monitoring_postgres_exporter_enabled: true
monitoring_postgres_exporter_pg_user: "monitor_user"
```

**Promtail**
```yaml
# defaults/main.yaml
monitoring_promtail_enabled: true
monitoring_promtail_host: 127.0.0.1
monitoring_promtail_port: 9080
monitoring_promtail_docker_bind: "127.0.0.1:127.0.0.1:9080"
monitoring_promtail_container_name: promtail
monitoring_promtail_image_version: latest

monitoring_promtail_modules_enabled:
  - "app2"

monitoring_promtail_modules_available:
  app1:
    log_path: "/var/log/app1/error.log"
    template: "app1.j2"
  app2:
    log_path: "/opt/app2/log/app2.log"
    template: "app2.j2"

monitoring_promtail_config_dir: "/etc/promtail"
monitoring_promtail_config_filename: "config.yml"
```

**Active users**
```yaml
monitoring_users_enabled: true
monitoring_users_host: 127.0.0.1
monitoring_users_port: 9839
monitoring_users_endpoint: "/metrics"
monitoring_users_prefix: "what"
monitoring_users_with_timestamp: false
monitoring_users_scrape_interval: 5000
```

**Odoo Instance API**
```yaml
monitoring_odoo_instance_api_enabled: false
monitoring_odoo_instance_api_runtime: "systemd" # "systemd" or "docker"
monitoring_odoo_instance_api_host: 127.0.0.1
monitoring_odoo_instance_api_port: 8000

# Systemd runtime
monitoring_odoo_instance_api_systemd_service_name: "odoo-instance-api"
monitoring_odoo_instance_api_systemd_user: "{{ ODOO_USER_NAME | default(odoo_role_odoo_user | default(monitoring_user_name)) }}"
monitoring_odoo_instance_api_systemd_group: "{{ monitoring_odoo_instance_api_systemd_user }}"
monitoring_odoo_instance_api_systemd_venv_path: "/home/{{ monitoring_odoo_instance_api_systemd_user }}/odoo-instance-api-venv"
monitoring_odoo_instance_api_package_name: "odoo-instance-api"
monitoring_odoo_instance_api_package_version: ""
monitoring_odoo_instance_api_log_level: "info"
monitoring_odoo_instance_api_odoo_venv_path: "/home/odoo/pyenv/versions/odoo-16/bin/python"
monitoring_odoo_instance_api_odoo_conf_path: "/etc/odoo/odoo.conf"

# Docker runtime
monitoring_odoo_instance_api_container_name: "odoo-instance-api"
monitoring_odoo_instance_api_image: "git.coopdevs.org:5050/coopdevs/sysadmin/monitoring/odoo-instance-api"
monitoring_odoo_instance_api_image_version: "latest"
monitoring_odoo_instance_api_docker_bind: "127.0.0.1:8000:8000"
monitoring_odoo_instance_api_docker_odoo_venv_path: "/home/odoo/pyenv/versions/odoo-16/bin/python"
monitoring_odoo_instance_api_docker_odoo_conf_path: "/etc/odoo/odoo.conf"
```

### Secret variables

**Promtail**
```yaml
monitoring_loki_user: "1234"
monitoring_loki_key: "eyJrIjoiM2VlZmM2NmQ4ZTQ4ZmE3MDRmZDBmMGE0YzNlNTE1MzRjZDdjNDY0N2YiLCJuIjoieW91ciBncmFmYW5hIGNsb3VkIGtleSIsImlkIjoxMjM0NTZ9"
monitoring_loki_hostname: "logs-somewhere.grafana.net"
```

**PostgresqlExporter**
```yaml
monitoring_postgres_exporter_pg_password: "3%hyZ&toNZ#Xn74"
monitoring_postgres_exporter_pg_port: "3456"
```
### Example playbooks

**Odoo with promtail**
```yaml
# playbooks/odoo-promtail.yml
---
- name: Install Odoo with logs monitoring
  hosts: servers
  become: yes
  roles:
    - role: coopdevs.odoo_role
    - role: coopdevs.monitoring_role
      vars:
        monitoring_nexporter_enabled: false
        monitoring_promtail_enabled: true
        monitoring_promtail_modules_enabled: [ "odoo" ]
        monitoring_loki_user: "1234"
        monitoring_loki_key: "eyJrIjoiM2VlZmM2NmQ4ZTQ4ZmE3MDRmZDBmMGE0YzNlNTE1MzRjZDdjNDY0N2YiLCJuIjoieW91ciBncmFmYW5hIGNsb3VkIGtleSIsImlkIjoxMjM0NTZ9"
        monitoring_loki_hostname: "logs-somewhere.grafana.net"
```

**PostgreSQL with system metrics**
```yaml
# playbooks/postgres-nexporter.yml
---
- name: Install a database server with exposed system metrics
  hosts: servers
  become: yes
  roles:
    - role: geerlingguy.postgresql
    - role: coopdevs.monitoring_role
      vars:
        monitoring_nexporter_enabled: true
        monitoring_promtail_enabled: false
```

**Odoo Instance API with systemd runtime (PyPI install)**
```yaml
# playbooks/odoo-instance-api-systemd.yml
---
- name: Install Odoo Instance API with monitoring role
  hosts: servers
  become: yes
  roles:
    - role: coopdevs.monitoring_role
      vars:
        monitoring_odoo_instance_api_enabled: true
        monitoring_odoo_instance_api_systemd_user: "{{ odoo_role_odoo_user }}"
        monitoring_odoo_instance_api_runtime: "systemd"
        monitoring_odoo_instance_api_host: "127.0.0.1"
        monitoring_odoo_instance_api_port: 8000
        monitoring_odoo_instance_api_odoo_venv_path: "/home/odoo/pyenv/versions/odoo-16/bin/python"
        monitoring_odoo_instance_api_odoo_conf_path: "/etc/odoo/odoo.conf"
```

**Odoo Instance API with docker runtime**
```yaml
# playbooks/odoo-instance-api-docker.yml
---
- name: Install Odoo Instance API with docker runtime
  hosts: servers
  become: yes
  roles:
    - role: coopdevs.monitoring_role
      vars:
        monitoring_odoo_instance_api_enabled: true
        monitoring_odoo_instance_api_runtime: "docker"
        monitoring_odoo_instance_api_host: "127.0.0.1"
        monitoring_odoo_instance_api_port: 8000
        monitoring_odoo_instance_api_image: "git.coopdevs.org:5050/coopdevs/sysadmin/monitoring/odoo-instance-api"
        monitoring_odoo_instance_api_image_version: "latest"
```

## Security

This role exposes through an HTTP server lots of data that can be potentially exploited. By default, it listens to a loopback adress, not public from the internet.

However, you probably want an external Prometheus server to fetch this data periodically. To this end, and to protect the data, some sort of authentication from the Prometheus server against the host is needed.

One approach is to leave the exporters binding to localhost and then set up a reverse proxy before them with Basic Authentication, using Nginx. The management of this set up and of the keys implied are out of the scope of this role.

## Extension

### A prometheus exporter

To add a new prometheus exporter:
1. Copy the `defaults/main.yml` section from Node Exporter at the same file and change all `nexporter` terms for yours, for instance, `someexporter`
2. Copy the `templates/monitoring-docker-compose.yml.j2` section of Node Exporter and again, rename and adapt to your needs.
3. Adapt `meta/main.yml`: add a tag, change description if needed.
4. Update `README.md`

### A promtail module for a new app

To add compatibility for an app that is not supported yet, do:
1. Declare it at `monitoring_promtail_modules_available`. Log path depends on the app, the template name you decide it here.
2. Copy the `templates/promtail-config-apps/odoo-role.j2` to the same dir but with filename `new-app.j2`
3. Edit template accordingly to your app. Check the [official docs](https://github.com/grafana/loki/tree/master/docs/clients/promtail).
  * You can test the regex at [regexr](https://regexr.com/) in "server mode" or [regex101.com](https://regex101.com)
    Include a comment with a couple of log entries for sake of clarity, it will help future regex readers.
  * Set the `labels` stage to define which labels are exported to Loki, among all of the collected ones.
  * Set the `timestamp` stage to timestamp the log line with the real one instead of the time that promtail scraped it.
      * Include milliseconds only if possible. Golang only understands fullstop '.' as decimal separator. If your app uses ',' it doesn't.
        See golang's issue [#6189](https://github.com/golang/go/issues/6189)
      * Include timezone either through the parsing as in `backups-role.j2` or manually as in `odoo-role.j2`
  * Optionally include a `match` stage if you want to drop entries that do not match your regex
