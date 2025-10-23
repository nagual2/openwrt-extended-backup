#!/bin/sh
set -eu

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)
SCRIPT_PATH="$PROJECT_ROOT/scripts/user_installed_packages"
STATUS_FIXTURE="$PROJECT_ROOT/tests/fixtures/opkg/status.sample"
USER_LIST="$PROJECT_ROOT/tests/fixtures/opkg/user-installed.list"
EXPECTED_DEFAULT="$PROJECT_ROOT/tests/fixtures/opkg/expected-default.txt"
EXPECTED_NO_LUCI="$PROJECT_ROOT/tests/fixtures/opkg/expected-no-luci.txt"
EXPECTED_INCLUDE_AUTO="$PROJECT_ROOT/tests/fixtures/opkg/expected-include-auto.txt"

TMP_DEFAULT=$(mktemp)
TMP_NO_LUCI=$(mktemp)
TMP_INCLUDE_AUTO=$(mktemp)

cleanup() {
	rm -f "$TMP_DEFAULT" "$TMP_NO_LUCI" "$TMP_INCLUDE_AUTO"
}

trap cleanup EXIT INT TERM

"$SCRIPT_PATH" --status-file "$STATUS_FIXTURE" --user-installed-file "$USER_LIST" >"$TMP_DEFAULT"
"$SCRIPT_PATH" --status-file "$STATUS_FIXTURE" --user-installed-file "$USER_LIST" --exclude 'luci-i18n-*' >"$TMP_NO_LUCI"
"$SCRIPT_PATH" --status-file "$STATUS_FIXTURE" --user-installed-file "$USER_LIST" --include-auto-deps >"$TMP_INCLUDE_AUTO"

diff -u "$EXPECTED_DEFAULT" "$TMP_DEFAULT"
diff -u "$EXPECTED_NO_LUCI" "$TMP_NO_LUCI"
diff -u "$EXPECTED_INCLUDE_AUTO" "$TMP_INCLUDE_AUTO"

printf 'All user_installed_packages tests passed.\n'
