# Changelog

## [0.2.0](https://github.com/nagual2/openwrt-extended-backup/compare/v0.1.0...v0.2.0) (2024-10-26)

### Highlights
- **Restore assistant.** Introduced `openwrt_full_restore` for safe, scriptable recovery with archive validation, dry-run mode, automatic backups of overwritten files, optional package reinstall, and service restarts.
- **Remote upload workflow.** `openwrt_full_backup` now streamlines off-device transfers: it defaults to SCP export, prints ready-to-run commands via `--emit-scp-cmd`, and lets you customise host, port, and user through `--ssh-host`, `--ssh-port`, and `--ssh-user`. SMB export remains available for LAN shares.
- **Packaged distribution.** Added official OpenWrt feed metadata and a local `Makefile` to build `.ipk` packages, including a toggle for the optional `ksmbd-tools` dependency.
- **Expanded verification.** Brought shell fixtures and end-to-end style tests to validate the user-installed package regeneration flow and guard against regressions.

### Documentation
- Refreshed the README with restore guidance, remote export usage, security notes, and `.ipk` build instructions.
- Published a dedicated recovery walkthrough in `docs/restore-guide.md`.

### Breaking changes
- None.

## [0.1.0](https://github.com/nagual2/openwrt-extended-backup/releases/tag/v0.1.0) (2024-09-15)

### Added
- Initial release of `openwrt_full_backup` for creating overlay archives with optional SMB export helpers.
- `user_installed_packages` utility to enumerate manually installed `opkg` packages and generate reinstall commands.

---

All notable changes to this project will be documented in this file.

The release workflow is driven by [release-please](https://github.com/googleapis/release-please) and will update this changelog automatically.
