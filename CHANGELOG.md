# Changelog

## [Unreleased]

### Features

* **restore:** add `openwrt_restore` script with safety snapshot, package reinstall flow, and docs/tests updates

## [0.8.3](https://github.com/nagual2/openwrt-extended-backup/compare/v0.8.2...v0.8.3) (2025-10-24)


### Bug Fixes

* **ci:** resolve CI failure by pinning shfmt to compatible version ([2280d04](https://github.com/nagual2/openwrt-extended-backup/commit/2280d045b91bf1b2a309b8ee0e1b04e737e17469))

## [0.8.2](https://github.com/nagual2/openwrt-extended-backup/compare/v0.8.1...v0.8.2) (2025-10-24)


### Bug Fixes

* **ci:** restore and stabilize shell script CI workflows ([1f327a0](https://github.com/nagual2/openwrt-extended-backup/commit/1f327a0f819f1f07d8a8e01e43b532b3f4dfe5ad))

## [0.8.1](https://github.com/nagual2/openwrt-extended-backup/compare/v0.8.0...v0.8.1) (2025-10-24)


### Bug Fixes

* **user_installed_packages:** rewrite to produce correct deterministic package list ([2005858](https://github.com/nagual2/openwrt-extended-backup/commit/2005858379410d8a7c7089e57b0a3572ea9095f7))

## [0.8.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.7.0...v0.8.0) (2025-10-24)


### Features

* **backup:** default to SCP export, new CLI flags, and robust SMB handling ([21653d8](https://github.com/nagual2/openwrt-extended-backup/commit/21653d8db8f413590fc3548096eb777a27f7e360))

## [0.7.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.6.0...v0.7.0) (2025-10-23)


### Features

* **user_installed_packages:** robust user package detection, commands, test, and docs ([5f13cbc](https://github.com/nagual2/openwrt-extended-backup/commit/5f13cbc0d62596da480ba2f7701fd519f15e021a))

## [0.6.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.5.0...v0.6.0) (2025-10-23)


### Features

* **github:** add pull request template for PR quality checks ([3c264ee](https://github.com/nagual2/openwrt-extended-backup/commit/3c264eef41d61f53ad5a47d5a54d858fd8d00cea))
* **openwrt,build:** add OpenWrt package/Makefile, .ipk build, and local Makefile ([9d4fd19](https://github.com/nagual2/openwrt-extended-backup/commit/9d4fd19a659c923b9f23e8222a714faa8f2f04e0))

## [0.5.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.4.1...v0.5.0) (2025-10-23)


### Features

* **ci,build,versioning:** add VERSION file, -V/--version flag, and automated GitHub Releases ([86f48b9](https://github.com/nagual2/openwrt-extended-backup/commit/86f48b901621557ead97b072dceba2b8101ec556))

## Changelog

All notable changes to this project will be documented in this file.

The release workflow is driven by [release-please](https://github.com/googleapis/release-please) and will update this changelog automatically.
