# Changelog

## [0.1.0](https://github.com/nagual2/openwrt-extended-backup/releases/tag/v0.1.0) (2025-10-25)

### Features

* **backup:** provide `openwrt_full_backup` CLI for capturing overlay archives with SCP, SMB, or local export workflows.
* **restore:** add `openwrt_full_restore` utility with safety checks, service restarts, and optional package reinstall support.
* **packages:** include `user_installed_packages` helper to generate deterministic reinstall scripts from opkg metadata.

### Tooling

* add OpenWrt packaging metadata and local Makefile helpers for building .ipk deliverables.
* configure release automation, documentation, and CI defaults for the initial public release.

## Changelog

All notable changes to this project will be documented in this file.

The release workflow is driven by [release-please](https://github.com/googleapis/release-please) and will update this changelog automatically.
