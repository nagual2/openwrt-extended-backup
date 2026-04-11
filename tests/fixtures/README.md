# Test fixtures

This directory contains data files consumed by the Bats test suite.

- `system/openwrt_release` — representative contents of `/etc/openwrt_release` used by `openwrt_full_backup` tests.
- `opkg/status.sample` and related files — baseline fixture set covering default, excluded LuCI translations and auto-dependency scenarios from the original smoke test.
- `opkg/status.special.sample` / `user-installed-special.list` / `expected-special.txt` — exercise package names with special characters (`+`, `@`) and additional user-maintained lists.
- `opkg/status.none.sample` / `expected-none.txt` — minimal `opkg` database without any user-installed packages for negative coverage.
