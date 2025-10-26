#!/usr/bin/env bats

load 'helpers/mocks'

setup() {
  mock_setup
  mock_use_fake_root
  mock_install_release_fixture

  OVERLAY_DIR="${MOCK_WORKSPACE}/overlay"
  mkdir -p "${OVERLAY_DIR}/upper/etc"
  printf 'example-data\n' >"${OVERLAY_DIR}/upper/etc/sample.txt"

  OUTPUT_DIR="${MOCK_WORKSPACE}/out"
  rm -rf "${OUTPUT_DIR}"
}

teardown() {
  unset KSMBD_PASSWORD
  mock_teardown
}

expected_archive_path() {
  printf '%s/fullbackup_OpenWrt_23.05.0_2024-01-01_00-00-00.tar.gz\n' "${OUTPUT_DIR}"
}

@test "creates archive in output directory" {
  mock_reset_command_log

  mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}"

  assert_success

  expected="$(expected_archive_path)"
  [ -f "${expected}" ]

  tar_line=$(grep '^tar ' "${MOCK_COMMAND_LOG}" | head -n 1)
  [[ "${tar_line}" == *"--numeric-owner"* ]]
  [[ "${tar_line}" == *"--same-owner"* ]]
  [[ "${tar_line}" == *"-X "* ]]
  [[ "${tar_line}" == *" overlay" ]]

  if grep -q 'ksmbd' "${MOCK_COMMAND_LOG}"; then
    fail "unexpected ksmbd invocation: $(cat "${MOCK_COMMAND_LOG}")"
  fi

  [[ "${output}" == *"Архив сохранён: ${expected}"* ]]
  [[ "${output}" == *"scp root@"* ]]
}

@test "dry-run skips tar invocation" {
  mock_reset_command_log

  mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}" --dry-run

  assert_success

  expected="$(expected_archive_path)"
  [[ "${output}" == *"Режим dry-run: архив не создавался"* ]]
  [[ "${output}" == *"${expected}"* ]]
  [ ! -f "${expected}" ]
  [ ! -d "${OUTPUT_DIR}" ]

  if grep -q '^tar ' "${MOCK_COMMAND_LOG}"; then
    fail "tar should not be executed in dry-run"
  fi
}

@test "SMB export configures ksmbd share" {
  mock_reset_command_log
  mock_install_ksmbd_service

  export KSMBD_PASSWORD='Secret123'

  mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}" --export=smb

  assert_success

  expected="$(expected_archive_path)"
  [ -f "${expected}" ]

  mock_assert_log_contains "ksmbd.adduser owrt_backup -p Secret123"
  mock_assert_log_contains "uci set ksmbd.@share[-1].path=${OUTPUT_DIR}"
  mock_assert_log_contains "uci commit ksmbd"
  mock_assert_log_contains "init.d/ksmbd restart"

  if grep -q 'ksmbd.deluser' "${MOCK_COMMAND_LOG}"; then
    fail "ksmbd.deluser should not be triggered on success"
  fi

  [[ "${output}" == *"SMB-шара доступна"* ]]
  [[ "${output}" == *"Пароль: Secret123"* ]]
}

@test "rejects unsupported export mode" {
  mock_reset_command_log

  mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}" --export=nfs

  assert_status 64
  [[ "${output}" == *"Неподдерживаемый режим экспорта: nfs"* ]]
}

@test "fails when overlay directory missing" {
  mock_reset_command_log

  missing="${MOCK_WORKSPACE}/missing-overlay"

  mock_run_backup --overlay "${missing}" --output "${OUTPUT_DIR}"

  assert_status 70
  [[ "${output}" == *"Каталог для архивации не найден"* ]]
}
