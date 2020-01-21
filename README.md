# Monitoring Role [![Ansible Role](https://img.shields.io/ansible/role/44192)](https://galaxy.ansible.com/coopdevs/monitoring_role)

An Ansible role for maintaining monitoring tools of the Grafana ecosystem.

Uses docker to install Prometheus and Loki exporters:
* `node_exporter`: prometheus exporter that collects general data about the state of a host.
* `promtail`: the main exporter for Loki, a logs server similar to Prometheus and compatible with Grafana.

This role supports some applications with their default logging format:
* [Odoo12](https://github.com/coopdevs/odoo-role)
* [Coopdevs backups](https://github.com/coopdevs/backups-role/)

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

### Secret variables

**Promtail**
```yaml
monitoring_loki_user: "1234"
monitoring_loki_key: "eyJrIjoiM2VlZmM2NmQ4ZTQ4ZmE3MDRmZDBmMGE0YzNlNTE1MzRjZDdjNDY0N2YiLCJuIjoieW91ciBncmFmYW5hIGNsb3VkIGtleSIsImlkIjoxMjM0NTZ9"
monitoring_loki_hostname: "logs-somewhere.grafana.net"
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
