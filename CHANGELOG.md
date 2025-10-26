# Changelog

All notable changes to this project will be documented in this file.

The release workflow is driven by [release-please](https://github.com/googleapis/release-please) and updates this changelog automatically.

## [0.1.0] - 2025-10-25

### Added
- Introduced the `openwrt_full_backup` utility for creating complete OpenWrt overlay archives with SCP, SMB, and local export options.
- Added the `openwrt_full_restore` utility with safety checks, interactive confirmations, and optional package reinstall sequencing.
- Added the `user_installed_packages` helper to generate deterministic reinstall scripts for manually installed opkg packages.
- Included packaging metadata and release automation to publish versioned archives and checksum manifests.
