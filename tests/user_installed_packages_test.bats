#!/usr/bin/env bats

setup() {
    PROJECT_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." 2>/dev/null && pwd)"
    SCRIPT_PATH="$PROJECT_ROOT/scripts/user_installed_packages"
    STATUS_FIXTURE="$PROJECT_ROOT/tests/fixtures/opkg/status.sample"
    USER_LIST="$PROJECT_ROOT/tests/fixtures/opkg/user-installed.list"
    EXPECTED_DEFAULT="$PROJECT_ROOT/tests/fixtures/opkg/expected-default.txt"
    EXPECTED_NO_LUCI="$PROJECT_ROOT/tests/fixtures/opkg/expected-no-luci.txt"
    EXPECTED_INCLUDE_AUTO="$PROJECT_ROOT/tests/fixtures/opkg/expected-include-auto.txt"
}

check_output() {
    local expected="$1"
    shift

    run "$SCRIPT_PATH" "$@"
    [ "$status" -eq 0 ]

    local actual="$BATS_TEST_TMPDIR/output.txt"
    printf '%s\n' "$output" >"$actual"
    diff -u "$expected" "$actual"
}

@test "generates default package list" {
    check_output "$EXPECTED_DEFAULT" \
        --status-file "$STATUS_FIXTURE" \
        --user-installed-file "$USER_LIST"
}

@test "honors exclude patterns" {
    check_output "$EXPECTED_NO_LUCI" \
        --status-file "$STATUS_FIXTURE" \
        --user-installed-file "$USER_LIST" \
        --exclude 'luci-i18n-*'
}

@test "includes auto dependencies when requested" {
    check_output "$EXPECTED_INCLUDE_AUTO" \
        --status-file "$STATUS_FIXTURE" \
        --user-installed-file "$USER_LIST" \
        --include-auto-deps
}
