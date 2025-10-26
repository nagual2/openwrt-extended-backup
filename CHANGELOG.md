# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v0.1.0] - 2024-10-25

### Added

- Introduced `openwrt_full_backup` to create reproducible archives of the writable overlay with `scp`, `local`, and `smb` export modes plus an `--emit-scp-cmd` helper for automation.
- Added optional SMB export orchestration through `ksmbd`, including automatic share provisioning, credential management, and recycling of existing shares when present.
- Introduced `user_installed_packages` to generate deterministic reinstall scripts for manually installed `opkg` packages with grouping, filtering, and support for supplemental package lists.
- Added automated formatting (`shfmt`), Bats-based tests, and documentation to support ongoing work on the scripts.
