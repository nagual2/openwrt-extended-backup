# OpenWrt extended backup toolkit

[![Shell quality checks](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/shell-quality.yml/badge.svg?branch=main)](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/shell-quality.yml)

A collection of POSIX shell utilities that run directly on OpenWrt routers. The tools help you export the writable overlay, restore a saved archive safely, and record the list of packages that were installed manually.

> The CLI output is currently in Russian. Behaviour and options are documented in English below until the localisation is updated.

## What is included

| Command | Purpose |
| --- | --- |
| `openwrt_full_backup` | Creates a tar.gz archive of `/overlay`, prints an scp command, and can expose the result over a temporary SMB share via `ksmbd`. |
| `openwrt_restore` | Validates a backup archive, extracts it into the target overlay, keeps snapshots of the current state, and optionally re-runs stored package installation scripts. |
| `user_installed_packages` | Produces a deterministic reinstall script for packages that were installed manually with `opkg`, with optional filters and external package lists. |

All scripts live in [`scripts/`](./scripts/) and share helper functions under [`scripts/lib`](./scripts/lib). Thin launchers keep the legacy command names available after the refactor.

## Requirements

- OpenWrt 22.03 or newer with BusyBox ≥ 1.35.
- `tar`, `coreutils-sha256sum`, and standard OpenWrt base utilities.
- Optional: `ksmbd-tools` to expose SMB shares from the backup script.
- Root access when restoring archives or writing into `/overlay`.

## Installation

### Download from a release

1. Grab the latest `.tar.gz` or `.zip` asset from [GitHub Releases](https://github.com/nagual2/openwrt-extended-backup/releases).
2. Extract the archive – it only contains the `scripts/` directory plus the documentation.
3. Copy the scripts you need to the router (for example with `scp`) and make them executable with `chmod +x`.

### Build and install the `.ipk`

```
make ipk            # builds dist/ctoolkit_<version>-1_all.ipk
make install        # installs the generated package with opkg when available
```

Set `WITH_KSMBD=0` if you do not want the package to depend on `ksmbd-tools`.

### Manual download

```
scp scripts/openwrt_full_backup root@<router>:/usr/sbin/
scp scripts/openwrt_restore root@<router>:/usr/sbin/
scp scripts/user_installed_packages root@<router>:/usr/bin/
chmod +x /usr/sbin/openwrt_full_backup /usr/sbin/openwrt_restore /usr/bin/user_installed_packages
```

## Usage

### `openwrt_full_backup`

```
openwrt_full_backup [--output PATH] [--overlay DIR] [--export=smb] [--dry-run]
```

- `--output PATH` – directory where the tar.gz archive will be written (`/tmp` by default).
- `--overlay DIR` – custom overlay source directory (`/overlay` by default).
- `--export=smb` – share the resulting archive over a temporary `ksmbd` share.
- `--dry-run` – verify requirements and show actions without creating the archive.
- `-V/--version`, `-h/--help` – print version or help text.

The command prints the absolute path to the generated archive and an `scp` command that can be executed from a workstation. When SMB export is enabled it also emits the credentials and share path to use.

### `openwrt_restore`

```
openwrt_restore [--archive PATH] [--packages PATH] [--dry-run] [--no-reboot]
                 [--overlay DIR] [--force]
```

- `--archive PATH` – location of the backup archive to restore. Prompts interactively when omitted.
- `--packages PATH` – script with `opkg` commands to reinstall packages after restoring the overlay.
- `--dry-run` – verify the archive, produce a report, and stop without modifying the system.
- `--no-reboot` – skip automatic reboot once the restore finishes.
- `--overlay DIR` – override the overlay mount point (useful for tests or recovery images).
- `--force` – bypass environment checks that normally guard against running outside OpenWrt.
- `-V/--version`, `-h/--help` – print version or help text.

The restore workflow verifies the tarball, optionally checks SHA-256 sums, extracts the archive into a temporary workspace, snapshots the current overlay, copies in files with preserved owners and modes, and restarts key services. When no `--packages` argument is given it uses `user_installed_packages` to regenerate the reinstall script automatically.

### `user_installed_packages`

```
user_installed_packages [--status-file PATH] [--user-installed-file PATH]
                        [--include-auto-deps[=BOOL]] [--output PATH]
                        [-x PATTERN]
```

- `--status-file PATH` – alternative `opkg` status file (defaults to `/usr/lib/opkg/status`).
- `--user-installed-file PATH` – merge additional package names from an external list.
- `-x/--exclude PATTERN` – exclude packages that match a shell glob (repeatable).
- `--include-auto-deps[=BOOL]` – include entries marked `Auto-Installed: yes`.
- `--output PATH` – write the output to a file (`-` keeps stdout).
- `-V/--version`, `-h/--help` – print version or help text.

The script emits grouped, sorted package names followed by ready-to-run `opkg install` commands. If the status file is absent it falls back to `opkg list-installed` to keep working on minimal systems.

## Development

```
make fmt    # format shell scripts with shfmt -w
make lint   # run ShellCheck against all executable shell scripts
make test   # execute the Bats test suite
make all    # shorthand for "make lint test"
```

Release packaging (`make ipk`) installs `openwrt_full_backup`, `openwrt_restore`, the compatibility launcher `openwrt_full_restore`, and `user_installed_packages` alongside the documentation. GitHub Releases publish the same set of runtime files without the development helpers or tests.

## License

This project is distributed under the terms of the [MIT License](./LICENSE).
