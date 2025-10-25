#!/usr/bin/env bats

# Coverage: Golden output, exclusion logic, auto-installed flag handling,
# complex opkg status parsing, and error paths for user_installed_packages.

load 'test_helper'

setup_file() {
    PROJECT_ROOT=$(project_root)
    PKG_SCRIPT="$PROJECT_ROOT/scripts/user_installed_packages"
    OPKG_FIXTURES="$PROJECT_ROOT/tests/fixtures/opkg"
}

@test "default fixture matches golden output" {
    local status="$OPKG_FIXTURES/status.sample"
    local user_list="$OPKG_FIXTURES/user-installed.list"
    run "$PKG_SCRIPT" --status-file "$status" --user-installed-file "$user_list"
    assert_success
    assert_normalized_equals "$output" "$OPKG_FIXTURES/expected-default.txt"
    [ -z "$stderr" ]
}

@test "exclude pattern removes luci translations" {
    local status="$OPKG_FIXTURES/status.sample"
    local user_list="$OPKG_FIXTURES/user-installed.list"
    run "$PKG_SCRIPT" --status-file "$status" --user-installed-file "$user_list" --exclude 'luci-i18n-*'
    assert_success
    assert_normalized_equals "$output" "$OPKG_FIXTURES/expected-no-luci.txt"
}

@test "include-auto flag keeps auto-installed packages" {
    local status="$OPKG_FIXTURES/status.sample"
    local user_list="$OPKG_FIXTURES/user-installed.list"
    run "$PKG_SCRIPT" --status-file "$status" --user-installed-file "$user_list" --include-auto-deps
    assert_success
    assert_normalized_equals "$output" "$OPKG_FIXTURES/expected-include-auto.txt"
}

@test "complex status with held packages and special names" {
    local status="$OPKG_FIXTURES/status.complex"
    run "$PKG_SCRIPT" --status-file "$status"
    assert_success
    assert_normalized_equals "$output" "$OPKG_FIXTURES/expected-complex-default.txt"
}

@test "complex status includes auto deps when requested" {
    local status="$OPKG_FIXTURES/status.complex"
    run "$PKG_SCRIPT" --status-file "$status" --include-auto-deps
    assert_success
    assert_normalized_equals "$output" "$OPKG_FIXTURES/expected-complex-include-auto.txt"
}

@test "empty inputs produce minimal output" {
    local status="$OPKG_FIXTURES/status.empty"
    local user_list="$OPKG_FIXTURES/user-empty.list"
    run "$PKG_SCRIPT" --status-file "$status" --user-installed-file "$user_list"
    assert_success
    assert_normalized_equals "$output" "$OPKG_FIXTURES/expected-empty.txt"
}

@test "missing status file surfaces descriptive error" {
    local missing="$BATS_TEST_TMPDIR/status-missing"
    run "$PKG_SCRIPT" --status-file "$missing"
    assert_exit_code 69
    assert_normalized_equals "$stderr" "$OPKG_FIXTURES/expected-missing-status.err" "$missing" '${STATUS_FILE}'
}

@test "missing user-installed list is reported" {
    local status="$OPKG_FIXTURES/status.sample"
    local missing="$BATS_TEST_TMPDIR/user-missing.list"
    run "$PKG_SCRIPT" --status-file "$status" --user-installed-file "$missing"
    assert_exit_code 69
    assert_normalized_equals "$stderr" "$OPKG_FIXTURES/expected-missing-user.err" "$missing" '${USER_LIST}'
}
