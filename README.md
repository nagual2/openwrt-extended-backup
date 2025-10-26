# OpenWrt Extended Backup

[![CI](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/ci.yml)

OpenWrt Extended Backup ships two lightweight POSIX shell scripts that run directly on your router:

- `openwrt_full_backup` creates a reproducible archive of the writable overlay and can expose it over SCP, keep it locally, or share it temporarily over SMB.
- `user_installed_packages` inspects `opkg` metadata and prints ready-to-run reinstall commands for the packages you installed manually.

Both scripts are designed to run under `/bin/sh` on stock OpenWrt systems without additional dependencies.

> The backup archive is stored in RAM by default (usually `/tmp`). Download it immediately and delete it from the router when you are done.

## Runtime requirements

- `/bin/sh` (BusyBox or another POSIX-compliant shell)
- `opkg` for package metadata lookups
- `uci` for managing optional SMB exports
- `tar` to build the overlay archive
- Optional: `ksmbd` service with `ksmbd.adduser` for SMB sharing (`openwrt_full_backup --export=smb`)

## Installation

### Download from the latest release

1. Grab the scripts from the latest GitHub release and copy them to your router:

   ```sh
   scp openwrt_full_backup root@192.168.1.1:/usr/sbin/openwrt_full_backup
   scp user_installed_packages root@192.168.1.1:/usr/bin/user_installed_packages
   ```

2. Mark them as executable on the router:

   ```sh
   chmod +x /usr/sbin/openwrt_full_backup /usr/bin/user_installed_packages
   ```

### Install directly from the repository

If you have direct internet access from the router, download the scripts in-place:

```sh
wget https://raw.githubusercontent.com/nagual2/openwrt-extended-backup/v0.1.0/scripts/openwrt_full_backup -O /usr/sbin/openwrt_full_backup
wget https://raw.githubusercontent.com/nagual2/openwrt-extended-backup/v0.1.0/scripts/user_installed_packages -O /usr/bin/user_installed_packages
chmod +x /usr/sbin/openwrt_full_backup /usr/bin/user_installed_packages
```

Adjust the destination paths if you prefer to keep the utilities elsewhere on your system.

## Usage

### `openwrt_full_backup`

Run the backup script as root on the router. By default, it stores the archive in `/tmp`, prints the full path, and shows an `scp` command that you can run from your workstation.

```sh
openwrt_full_backup --out-dir /tmp/backups --emit-scp-cmd
```

Sample output:

```text
2024-10-25 12:00:00 INFO Creating archive: /tmp/backups/fullbackup_OpenWrt_2024-10-25_12-00-00.tar.gz
2024-10-25 12:00:02 INFO Archive saved: /tmp/backups/fullbackup_OpenWrt_2024-10-25_12-00-00.tar.gz
2024-10-25 12:00:02 INFO Ready-to-run SCP command: scp root@OpenWrt:/tmp/backups/fullbackup_OpenWrt_2024-10-25_12-00-00.tar.gz <destination>
```

To expose the archive over SMB for a short period, ensure `ksmbd` is installed and run:

```sh
openwrt_full_backup --export=smb --out-dir /tmp/backups
```

The script configures (or reuses) a `\\<router-ip>\\owrt_archive` share with read-only access. Remember to stop `ksmbd` and delete the archive once you have copied it.

### `user_installed_packages`

Produce the reinstall script for manually installed packages:

```sh
user_installed_packages > /tmp/opkg-user-packages.sh
```

Example output:

```text
# user-installed opkg packages (6)
# main packages (5)
bash
luci-app-sqm
luci-theme-material
tailscale
htop
# LuCI translations (1)
luci-i18n-firewall-ru
opkg update
opkg install bash luci-app-sqm luci-theme-material tailscale htop
opkg install luci-i18n-firewall-ru
```

You can exclude patterns, include auto-installed dependencies, or analyze a different status file with the relevant CLI flags (`--exclude`, `--include-auto-deps`, `--status-file`, `--user-installed-file`).

## Development

The project targets POSIX `/bin/sh`. Please keep new changes compatible with BusyBox `sh`.

- Format shell scripts with [`shfmt`](https://github.com/mvdan/sh):

  ```sh
  shfmt -d openwrt_full_backup user_installed_packages scripts/
  ```

- Run the test suite with [`bats`](https://github.com/bats-core/bats-core):

  ```sh
  bats tests
  ```

The CI workflow defined in `ci.yml` runs the same formatting and test checks.

## Releases

- The current version is stored in the root `VERSION` file.
- Both scripts expose `-V`/`--version` to print the version without executing the main logic.
- The workflow [`.github/workflows/release.yml`](.github/workflows/release.yml) runs on tags matching `v*`, builds `openwrt-extended-backup-${VERSION}.tar.gz` and `.zip`, generates `SHA256SUMS`, and publishes a GitHub Release using the matching section from `CHANGELOG.md`.
- To publish a new release manually (example for `v0.1.0`):
  1. Update `VERSION`: `printf '0.1.0\n' > VERSION`.
  2. Add or update the `## [v0.1.0]` section in `CHANGELOG.md` with the release notes.
  3. Commit the changes: `git commit -am "chore: prepare release 0.1.0"`.
  4. Create an annotated tag: `git tag -a v0.1.0 -m "v0.1.0"`.
  5. Push the branch and tag: `git push origin main && git push origin v0.1.0`.
  6. Wait for GitHub Actions to publish the release with packaged archives and `SHA256SUMS`.
