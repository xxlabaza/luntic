
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

[Tags on this repository](https://github.com/xxlabaza/luntic/tags)

## [Unreleased]

- Add `docker` build task, for creating a Docker image.

## [1.0.1](https://github.com/xxlabaza/luntic/releases/tag/1.0.1) - 2017-07-24

### Added
- `X-Expired-Time` header in creation response, for telling in which time client should make `PUT` request again. If `--heartbeat` option is not set - this header will have `0` value.

### Changed
- Corrected README.md file

## [1.0.0](https://github.com/xxlabaza/luntic/releases/tag/1.0.0) - 2017-07-22

Initial release.

### Added
- CRUD endpoints for service registration and management.
- Scheduled periodical task for removing expired records.
- Dashborad, which you could launch on separate port and open in your web browser.
