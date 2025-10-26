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

@test "user_installed_packages parses complex status metadata" {
  status_file="${MOCK_FIXTURES_DIR}/opkg/status.complex"
  expected_file="${MOCK_FIXTURES_DIR}/opkg/expected-complex-default.txt"

  mock_run_user_installed --status-file "${status_file}"

  assert_success
  assert_output_equals_fixture "${expected_file}"
}

@test "user_installed_packages includes auto deps for complex status when requested" {
  status_file="${MOCK_FIXTURES_DIR}/opkg/status.complex"
  expected_file="${MOCK_FIXTURES_DIR}/opkg/expected-complex-include-auto.txt"

  mock_run_user_installed --status-file "${status_file}" --include-auto-deps

  assert_success
  assert_output_equals_fixture "${expected_file}"
}

@test "user_installed_packages writes output to a file" {
  status_file="${MOCK_FIXTURES_DIR}/opkg/status.sample"
  user_list="${MOCK_FIXTURES_DIR}/opkg/user-installed.list"
  expected_file="${MOCK_FIXTURES_DIR}/opkg/expected-default.txt"
  output_path="${BATS_TEST_TMPDIR}/packages.txt"

  mock_run_user_installed --status-file "${status_file}" --user-installed-file "${user_list}" --output "${output_path}"

  assert_success
  [[ -z "${output}" ]]

  run diff -u "${expected_file}" "${output_path}"
  [ "${status}" -eq 0 ]
}

@test "user_installed_packages falls back to opkg list-installed when status file is unavailable" {
  expected_file="${MOCK_FIXTURES_DIR}/opkg/expected-default.txt"
  user_list="${MOCK_FIXTURES_DIR}/opkg/user-installed.list"
  opkg_handler="${MOCK_COMMAND_HANDLER_DIR}/opkg"

  cat >"${opkg_handler}" <<'EOF'
#!/bin/sh
cat <<'DATA'
bash - 5.0
htop - 3.2.2-1
luci-app-sqm - git-23.229.27387-1
luci-i18n-firewall-ru - git-23.229.27387-1
tailscale - 1.64.0-1
DATA
EOF
  chmod +x "${opkg_handler}"

  missing_status="${BATS_TEST_TMPDIR}/missing-status"
  rm -f "${missing_status}"

  DEFAULT_STATUS_FILE="${missing_status}" mock_run_user_installed --user-installed-file "${user_list}"

  assert_success
  assert_output_equals_fixture "${expected_file}"
}
