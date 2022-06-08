# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v0.4.5] - 2022-06-08
Fix [backup monitoring](https://github.com/coopdevs/handbook/wiki/Backup-Monitoring)
### Fixed
- Promtail scrape config [#24](https://github.com/coopdevs/monitoring-role/pull/24/)

## [v0.4.4] - 2022-04-22
Improve [backup monitoring](https://github.com/coopdevs/handbook/wiki/Backup-Monitoring) capabilities.
### Added
- Update the promtail client endpoint. [#20]
- Add restic-stderr.log to promtail paths [#20]
### Fixed
- Change exporters tag names (they're now linter-compliant) [#20]
- Other minor linter fixes. [#20]

## [v0.4.3] - 2022-02-16
### Added
- Add var to configure the PG port [#18]

## [v0.4.2] - 2021-12-10
### Added
- Add default value for psql flag and set promtail to false [#17]

## [v0.4.1] - 2021-10-22
### Fixed
- Removed references to Odoo in README.md [#13]
- Escape dollar sign in pg exporter user password [#15]

## [v0.4.0] - 2021-10-20
- Added Postgresql Exporter [#11]

## [v0.3.1] - 2021-01-05
### Fixed
- Execute the Promtail tasks only if Promtail is enabled. [#10]

## [v0.3.0] - 2020-01-21
### Added
- Add Promtail "module" for odoo-role
- Add example secrets file. Shows which secrets are needed by promtail.
- New sections at README: Extend the role, example playbooks, promtail vars, promtail secrets

### Changed
- Improve the modularity of the promtail config template.
  To add a new module, add an entry to `monitoring_promtail_modules_available`.
  At the inventory, add its name to `monitoring_promtail_modules_enabled`.
- Fix bug with yaml syntax of Galaxy meta. Role dependencies are now recognized
- Change role's description for Ansible Galaxy and add tags.
- Updated README with up-to-date node exporter var names and changed general description to include promtail.


## [v0.2.0] - 2020-01-13
### Added
- Start keeping a changelog.
- Install and configure promtail (can be enabled/disabled).
- Promtail can watch many application logs and enable or disable them at each host.
- Promtail job template for backups-role.
- At backups-role template, use "instance" label instead of the documented "host" label name in order to unify naming with prometheus.
