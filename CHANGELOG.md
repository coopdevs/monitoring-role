# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Start keeping a changelog.
- Install and configure promtail (can be enabled/disabled).
- Promtail can watch many application logs and enable or disable them at each host.
- Promtail job template for backups-role.
- At backups-role template, use "instance" label instead of the documented "host" label name in order to unify naming with prometheus.
