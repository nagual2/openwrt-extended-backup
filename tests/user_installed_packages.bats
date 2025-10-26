#!/usr/bin/env bats

load 'helpers/mocks'

setup() {
  mock_setup
}

teardown() {
  mock_teardown
}

assert_output_equals_fixture() {
  local fixture_path="$1"
  local expected
  expected="$(cat "${fixture_path}")"
  if [[ "${output}" != "${expected}" ]]; then
    fail "output mismatch; expected contents of ${fixture_path}"
  fi
}

@test "user_installed_packages prints default reinstall commands" {
  status_file="${MOCK_FIXTURES_DIR}/opkg/status.sample"
  user_list="${MOCK_FIXTURES_DIR}/opkg/user-installed.list"
  expected_file="${MOCK_FIXTURES_DIR}/opkg/expected-default.txt"

  mock_run_user_installed --status-file "${status_file}" --user-installed-file "${user_list}"

  assert_success
  assert_output_equals_fixture "${expected_file}"
}

@test "user_installed_packages supports excluding luci translations" {
  status_file="${MOCK_FIXTURES_DIR}/opkg/status.sample"
  user_list="${MOCK_FIXTURES_DIR}/opkg/user-installed.list"
  expected_file="${MOCK_FIXTURES_DIR}/opkg/expected-no-luci.txt"

  mock_run_user_installed --status-file "${status_file}" --user-installed-file "${user_list}" --exclude 'luci-i18n-*'

  assert_success
  assert_output_equals_fixture "${expected_file}"
}

@test "user_installed_packages can include auto dependencies" {
  status_file="${MOCK_FIXTURES_DIR}/opkg/status.sample"
  user_list="${MOCK_FIXTURES_DIR}/opkg/user-installed.list"
  expected_file="${MOCK_FIXTURES_DIR}/opkg/expected-include-auto.txt"

  mock_run_user_installed --status-file "${status_file}" --user-installed-file "${user_list}" --include-auto-deps

  assert_success
  assert_output_equals_fixture "${expected_file}"
}

@test "user_installed_packages handles special-character package names" {
  status_file="${MOCK_FIXTURES_DIR}/opkg/status.special.sample"
  user_list="${MOCK_FIXTURES_DIR}/opkg/user-installed-special.list"
  expected_file="${MOCK_FIXTURES_DIR}/opkg/expected-special.txt"

  mock_run_user_installed --status-file "${status_file}" --user-installed-file "${user_list}"

  assert_success
  assert_output_equals_fixture "${expected_file}"
}

@test "user_installed_packages reports no user packages" {
  status_file="${MOCK_FIXTURES_DIR}/opkg/status.none.sample"
  expected_file="${MOCK_FIXTURES_DIR}/opkg/expected-none.txt"

  mock_run_user_installed --status-file "${status_file}"

  assert_success
  assert_output_equals_fixture "${expected_file}"
}
