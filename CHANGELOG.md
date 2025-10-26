# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.8.3...v0.9.0) (2025-10-26)


### Features

* **backup:** add dry-run mode and --output option to openwrt_full_backup ([d459862](https://github.com/nagual2/openwrt-extended-backup/commit/d4598628cd48813260b148b94377b0f729b293b7))
* **backup:** add dry-run output tests and validation ([2047ca6](https://github.com/nagual2/openwrt-extended-backup/commit/2047ca675f1a9db4106fa94a7c7fc37c70ae900c))
* **backup:** add SCP/SFTP upload for remote backup export ([9360359](https://github.com/nagual2/openwrt-extended-backup/commit/936035948a862e23b400c37f8212758c8bbd94b1))
* **backup:** add SCP/SFTP upload for remote backup export ([635a292](https://github.com/nagual2/openwrt-extended-backup/commit/635a2926b469fa65dece8d1348948182d2f652e7))
* **ci:** publish signed opkg feed to GitHub Pages on release tag ([bbba9ff](https://github.com/nagual2/openwrt-extended-backup/commit/bbba9ff77eea2d48cbf38806a3ec15161faced42))
* **ci:** publish signed opkg feed to GitHub Pages on release tag ([71aac37](https://github.com/nagual2/openwrt-extended-backup/commit/71aac3702f2454a0ad20021c018aca5b6c6492b2))
* **helpers:** add install/uninstall scripts with BATS tests ([8748f51](https://github.com/nagual2/openwrt-extended-backup/commit/8748f519c275aab71b816cc51938c3a46e6d604b))
* **helpers:** add install/uninstall scripts with BATS tests ([4f5edb3](https://github.com/nagual2/openwrt-extended-backup/commit/4f5edb3475eb63d2580f1f9e63d2e3ead5a4a699))

## [Unreleased]

## [v0.1.0] - 2024-10-25

### Added

- Introduced `openwrt_full_backup` to create reproducible archives of the writable overlay with `scp`, `local`, and `smb` export modes plus an `--emit-scp-cmd` helper for automation.
- Added optional SMB export orchestration through `ksmbd`, including automatic share provisioning, credential management, and recycling of existing shares when present.
- Introduced `user_installed_packages` to generate deterministic reinstall scripts for manually installed `opkg` packages with grouping, filtering, and support for supplemental package lists.
- Added automated formatting (`shfmt`), Bats-based tests, and documentation to support ongoing work on the scripts.
