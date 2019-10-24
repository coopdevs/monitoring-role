# Monitoring Role

An Ansible role for maintaining monitoring tools of the Grafana ecosystem.

Uses docker to install the Prometheus exporter `node_exporter`, that collects general data about the state of a host.
We plan to add also `promtail`, the main exporter for Loki, a logs server similar to Prometheus and compatible with Grafana.

## Using this role

### Public variables

```yaml
# NodeExporter
monitoring_nexporter_enabled: true
monitoring_nexporter_localhost_uri: 127.0.0.1:9100
monitoring_nexporter_container_name: nexporter
monitoring_nexporter_image_version: latest
```

### Secret variables

```yaml
# TODO: application keys for loki
```

### Example playbook

```yaml
# TBD
```

## Security

This role exposes through an HTTP server lots of data that can be potentially exploited. By default, it listens to a loopback adress, not public from the internet. However, you probably want an external Prometheus server to fetch this data periodically. To this end, and to protect the data, some sort of authentication from the Prometheus server against the host is needed.
One approach is to leave the exporters binding to localhost and then set up a reverse proxy before them with Basic Authentication, using Nginx. The management of this set up and of the keys implied are out of the scope of this role.