# Changelog

All notable changes to this project will be documented in this file.

Tagged releases are published via GitHub Actions and update this changelog alongside the release artifacts.

## [0.8.3](https://github.com/nagual2/openwrt-extended-backup/compare/v0.8.2...v0.8.3) (2025-10-24)

### Bug Fixes

* **ci:** resolve CI failure by pinning shfmt to compatible version

## [0.8.2](https://github.com/nagual2/openwrt-extended-backup/compare/v0.8.1...v0.8.2) (2025-10-24)

### Bug Fixes

* **ci:** restore and stabilize shell script CI workflows

## [0.8.1](https://github.com/nagual2/openwrt-extended-backup/compare/v0.8.0...v0.8.1) (2025-10-24)

### Bug Fixes

* **user_installed_packages:** rewrite to produce correct deterministic package list

## [0.8.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.7.0...v0.8.0) (2025-10-24)

### Features

* **backup:** default to SCP export, new CLI flags, and robust SMB handling

## [0.7.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.6.0...v0.7.0) (2025-10-23)

### Features

* **user_installed_packages:** robust user package detection, commands, test, and docs

## [0.6.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.5.0...v0.6.0) (2025-10-23)

### Features

* **github:** add pull request template for PR quality checks
* **openwrt,build:** add OpenWrt package/Makefile, .ipk build, and local Makefile

## [0.5.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.4.1...v0.5.0) (2025-10-23)

### Features

* **ci,build,versioning:** add VERSION file, -V/--version flag, and automated GitHub Releases

## [v0.1.0] - 2024-10-25

### Added

- Introduced openwrt_full_backup to create reproducible archives of the writable overlay with scp, local, and smb export modes plus an --emit-scp-cmd helper for automation.
- Added optional SMB export orchestration through ksmbd, including automatic share provisioning, credential management, and recycling of existing shares when present.
- Introduced user_installed_packages to generate deterministic reinstall scripts for manually installed opkg packages with grouping, filtering, and support for supplemental package lists.
- Added automated formatting (shfmt), Bats-based tests, and documentation to support ongoing work on the scripts.

## [Unreleased]

