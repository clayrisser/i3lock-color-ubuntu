# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Containerized build via `make` / `scripts/build-package.sh`, replacing the
  bzr, `dh_make` and `xdotool` based flow
- `debian/watch`, `debian/gbp.conf` and `debian/upstream/metadata`
- `Conflicts`, `Replaces` and `Provides` on `i3lock`, without which the
  package could never unpack alongside the archive `i3lock`

### Changed
- Upstream moved from the abandoned eBrnd repository to
  [Raymo111/i3lock-color](https://github.com/Raymo111/i3lock-color)
- Updated to upstream 2.13.c.5
- Packaging moved from `src/debian/` to `debian/`
- Switched to `debhelper-compat (= 13)` and Standards-Version 4.7.4

### Removed
- The Launchpad PPA publishing flow, which has been dead for years

## [0.0.1] - 2018-12-15
### Added
- Initial release
