#!/usr/bin/env bats

load 'helpers/mocks'

declare -a SHELL_MATRIX_PATHS=()
declare -a SHELL_MATRIX_LABELS=()

setup_shell_matrix() {
  SHELL_MATRIX_PATHS=()
  SHELL_MATRIX_LABELS=()

  SHELL_MATRIX_PATHS+=('/bin/sh')
  SHELL_MATRIX_LABELS+=('/bin/sh')

  if command -v busybox >/dev/null 2>&1 && busybox ash -c 'exit 0' >/dev/null 2>&1; then
    local wrapper="${BATS_TEST_TMPDIR}/busybox-ash"
    cat <<'EOF' >"${wrapper}"
#!/bin/sh
exec busybox ash "$@"
EOF
    chmod +x "${wrapper}"
    SHELL_MATRIX_PATHS+=("${wrapper}")
    SHELL_MATRIX_LABELS+=('busybox ash')
  fi
}

reset_overlay_fixture() {
  rm -rf "${OVERLAY_DIR}"
  mkdir -p "${OVERLAY_DIR}/upper/etc/config"
  mkdir -p "${OVERLAY_DIR}/upper/run"
  mkdir -p "${OVERLAY_DIR}/upper/usr/lib"
  mkdir -p "${OVERLAY_DIR}/work"
  printf 'example-data\n' >"${OVERLAY_DIR}/upper/etc/sample.txt"
  printf 'config system\n' >"${OVERLAY_DIR}/upper/etc/config/system"
  printf "DISTRIB_DESCRIPTION='%s'\n" "OpenWrt 23.05.0" >"${OVERLAY_DIR}/upper/etc/os-release"
  printf 'NAME="OpenWrt"\n' >"${OVERLAY_DIR}/upper/usr/lib/os-release"
  touch "${OVERLAY_DIR}/upper/run/skip-me"
  mkfifo "${OVERLAY_DIR}/upper/run/fifo" >/dev/null 2>&1 || true
  touch "${OVERLAY_DIR}/work/.placeholder"
}

install_failing_ksmbd_service() {
  mkdir -p "$(dirname "${KSMBD_INIT_SCRIPT}")"
  cat >"${KSMBD_INIT_SCRIPT}" <<'EOF'
#!/bin/sh
set -eu
log=${MOCK_COMMAND_LOG-}
if [ -n "$log" ]; then
  {
    printf 'init.d/ksmbd'
    for arg in "$@"; do
      printf ' %s' "$arg"
    done
    printf '\n'
  } >>"$log"
fi
exit 1
EOF
  chmod +x "${KSMBD_INIT_SCRIPT}"
}

expected_archive_path() {
  printf '%s/fullbackup_OpenWrt_23.05.0_2024-01-01_00-00-00.tar.gz\n' "${OUTPUT_DIR}"
}

assert_output_contains() {
  local haystack="$1"
  local needle="$2"
  local shell_label="$3"
  if ! printf '%s\n' "$haystack" | grep -F -- "$needle" >/dev/null 2>&1; then
    fail "[${shell_label}] expected output to contain: ${needle}"
  fi
}

assert_command_log_contains() {
  local phrase="$1"
  local shell_label="$2"
  if ! grep -F -- "$phrase" "${MOCK_COMMAND_LOG}" >/dev/null 2>&1; then
    fail "[${shell_label}] expected command log to contain: ${phrase}"
  fi
}

assert_command_log_absent() {
  local phrase="$1"
  local shell_label="$2"
  if grep -F -- "$phrase" "${MOCK_COMMAND_LOG}" >/dev/null 2>&1; then
    fail "[${shell_label}] unexpected command log entry: ${phrase}"
  fi
}

setup() {
  mock_setup
  mock_use_fake_root
  mock_install_release_fixture

  OVERLAY_DIR="${MOCK_WORKSPACE}/overlay"
  OUTPUT_DIR="${MOCK_WORKSPACE}/out"

  setup_shell_matrix
  reset_overlay_fixture
  rm -rf "${OUTPUT_DIR}"
}

teardown() {
  unset KSMBD_PASSWORD
  unset MOCK_BACKUP_SHELL
  unset MOCK_IP_OUTPUT
  unset MOCK_IP_EXIT_CODE
  unset MOCK_HOSTNAME_VALUE
  unset MOCK_UCI_SHOW_KSMBD
  unset MOCK_FAIL_TAR
  unset MOCK_FAIL_TAR_MESSAGE
  unset MOCK_FAIL_TAR_EXIT_CODE
  mock_teardown
}

@test "creates archive in output directory across shells" {
  for idx in "${!SHELL_MATRIX_PATHS[@]}"; do
    local shell_label="${SHELL_MATRIX_LABELS[$idx]}"
    local shell_path="${SHELL_MATRIX_PATHS[$idx]}"

    reset_overlay_fixture
    rm -rf "${OUTPUT_DIR}"
    mock_reset_command_log

    local expected
    expected="$(expected_archive_path)"
    rm -f "${expected}"

    MOCK_BACKUP_SHELL="${shell_path}"
    mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}"
    local run_status=$status
    local run_output="${output}"
    unset MOCK_BACKUP_SHELL

    if [ "${run_status}" -ne 0 ]; then
      fail "[${shell_label}] expected success, got ${run_status}: ${run_output}"
    fi

    if [ ! -f "${expected}" ]; then
      fail "[${shell_label}] expected archive at ${expected}"
    fi

    local tar_line
    tar_line=$(grep '^tar ' "${MOCK_COMMAND_LOG}" | tail -n 1 || true)
    if [ -z "${tar_line}" ]; then
      fail "[${shell_label}] tar invocation missing"
    fi
    case "${tar_line}" in
      *"--numeric-owner"*) ;;
      *) fail "[${shell_label}] tar missing --numeric-owner: ${tar_line}" ;;
    esac
    case "${tar_line}" in
      *"--same-owner"*) ;;
      *) fail "[${shell_label}] tar missing --same-owner: ${tar_line}" ;;
    esac
    case "${tar_line}" in
      *"-X ${MOCK_TMP_DIR}/tar-exclude."*) ;;
      *) fail "[${shell_label}] tar missing exclude file: ${tar_line}" ;;
    esac
    case "${tar_line}" in
      *" overlay") ;;
      *) fail "[${shell_label}] tar missing overlay directory: ${tar_line}" ;;
    esac

    if grep -F -- 'ksmbd' "${MOCK_COMMAND_LOG}" >/dev/null 2>&1; then
      local command_log_dump
      command_log_dump=$(cat "${MOCK_COMMAND_LOG}")
      fail "[${shell_label}] unexpected ksmbd invocation: ${command_log_dump}"
    fi

    assert_output_contains "${run_output}" "Архив сохранён: ${expected}" "${shell_label}"
    assert_output_contains "${run_output}" "scp root@mock-router:${expected}" "${shell_label}"

    rm -rf "${OUTPUT_DIR}"
  done
}

@test "dry-run skips tar invocation across shells" {
  for idx in "${!SHELL_MATRIX_PATHS[@]}"; do
    local shell_label="${SHELL_MATRIX_LABELS[$idx]}"
    local shell_path="${SHELL_MATRIX_PATHS[$idx]}"

    reset_overlay_fixture
    rm -rf "${OUTPUT_DIR}"
    mock_reset_command_log

    local expected
    expected="$(expected_archive_path)"
    rm -f "${expected}"

    MOCK_BACKUP_SHELL="${shell_path}"
    mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}" --dry-run
    local run_status=$status
    local run_output="${output}"
    unset MOCK_BACKUP_SHELL

    if [ "${run_status}" -ne 0 ]; then
      fail "[${shell_label}] expected dry-run success, got ${run_status}: ${run_output}"
    fi

    [ ! -f "${expected}" ] || fail "[${shell_label}] dry-run should not create archive"
    [ ! -d "${OUTPUT_DIR}" ] || fail "[${shell_label}] dry-run should not create output directory"

    assert_output_contains "${run_output}" "Режим dry-run: архив не создавался" "${shell_label}"
    assert_output_contains "${run_output}" "${expected}" "${shell_label}"

    if grep -q '^tar ' "${MOCK_COMMAND_LOG}"; then
      fail "[${shell_label}] tar should not be executed during dry-run"
    fi
  done
}

@test "SMB export configures ksmbd share across shells" {
  mock_install_ksmbd_service

  for idx in "${!SHELL_MATRIX_PATHS[@]}"; do
    local shell_label="${SHELL_MATRIX_LABELS[$idx]}"
    local shell_path="${SHELL_MATRIX_PATHS[$idx]}"

    reset_overlay_fixture
    rm -rf "${OUTPUT_DIR}"
    mock_reset_command_log

    local expected
    expected="$(expected_archive_path)"
    rm -f "${expected}"

    export KSMBD_PASSWORD='Secret123'
    export MOCK_IP_OUTPUT=$'2: br-lan    inet 192.168.50.1/24 brd 192.168.50.255 scope global br-lan\n'
    export MOCK_IP_EXIT_CODE=0
    export MOCK_HOSTNAME_VALUE='integration-router'

    MOCK_BACKUP_SHELL="${shell_path}"
    mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}" --export=smb
    local run_status=$status
    local run_output="${output}"
    unset MOCK_BACKUP_SHELL

    unset KSMBD_PASSWORD
    unset MOCK_IP_OUTPUT
    unset MOCK_IP_EXIT_CODE
    unset MOCK_HOSTNAME_VALUE

    if [ "${run_status}" -ne 0 ]; then
      fail "[${shell_label}] expected SMB export success, got ${run_status}: ${run_output}"
    fi

    [ -f "${expected}" ] || fail "[${shell_label}] expected archive at ${expected}"

    assert_command_log_contains "ksmbd.adduser owrt_backup -p Secret123" "${shell_label}"
    assert_command_log_contains "uci set ksmbd.@share[-1].path=${OUTPUT_DIR}" "${shell_label}"
    assert_command_log_contains "uci commit ksmbd" "${shell_label}"
    assert_command_log_contains "init.d/ksmbd restart" "${shell_label}"

    assert_command_log_absent "ksmbd.deluser" "${shell_label}"

    assert_output_contains "${run_output}" "SMB-шара доступна по адресу \\192.168.50.1\\owrt_archive" "${shell_label}"
    assert_output_contains "${run_output}" "SMB-шара доступна по имени \\integration-router\\owrt_archive" "${shell_label}"
    assert_output_contains "${run_output}" "Имя пользователя: owrt_backup" "${shell_label}"
    assert_output_contains "${run_output}" "Пароль: Secret123" "${shell_label}"

    rm -rf "${OUTPUT_DIR}"
  done
}

@test "fails and removes partial archive when tar fails" {
  for idx in "${!SHELL_MATRIX_PATHS[@]}"; do
    local shell_label="${SHELL_MATRIX_LABELS[$idx]}"
    local shell_path="${SHELL_MATRIX_PATHS[$idx]}"

    reset_overlay_fixture
    rm -rf "${OUTPUT_DIR}"
    mock_reset_command_log

    local expected
    expected="$(expected_archive_path)"
    rm -f "${expected}"

    export MOCK_FAIL_TAR=1
    export MOCK_FAIL_TAR_MESSAGE='tar failure'
    export MOCK_FAIL_TAR_EXIT_CODE=2

    MOCK_BACKUP_SHELL="${shell_path}"
    mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}"
    local run_status=$status
    local run_output="${output}"
    unset MOCK_BACKUP_SHELL

    unset MOCK_FAIL_TAR
    unset MOCK_FAIL_TAR_MESSAGE
    unset MOCK_FAIL_TAR_EXIT_CODE

    if [ "${run_status}" -ne 70 ]; then
      fail "[${shell_label}] expected EX_SOFTWARE (70), got ${run_status}: ${run_output}"
    fi

    assert_output_contains "${run_output}" "Не удалось создать архив" "${shell_label}"
    assert_command_log_contains "tar -czpf ${expected}" "${shell_label}"
    [ ! -f "${expected}" ] || fail "[${shell_label}] archive should not exist after tar failure"

    rm -rf "${OUTPUT_DIR}"
  done
}

@test "SMB restart failure triggers cleanup" {
  install_failing_ksmbd_service

  for idx in "${!SHELL_MATRIX_PATHS[@]}"; do
    local shell_label="${SHELL_MATRIX_LABELS[$idx]}"
    local shell_path="${SHELL_MATRIX_PATHS[$idx]}"

    reset_overlay_fixture
    rm -rf "${OUTPUT_DIR}"
    mock_reset_command_log

    local expected
    expected="$(expected_archive_path)"
    rm -f "${expected}"

    export KSMBD_PASSWORD='Secret123'

    MOCK_BACKUP_SHELL="${shell_path}"
    mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}" --export=smb
    local run_status=$status
    local run_output="${output}"
    unset MOCK_BACKUP_SHELL

    unset KSMBD_PASSWORD

    if [ "${run_status}" -ne 70 ]; then
      fail "[${shell_label}] expected failure status 70 when ksmbd restart fails, got ${run_status}: ${run_output}"
    fi

    assert_output_contains "${run_output}" "Не удалось перезапустить службу ksmbd" "${shell_label}"
    assert_command_log_contains "ksmbd.adduser owrt_backup -p Secret123" "${shell_label}"
    assert_command_log_contains "init.d/ksmbd restart" "${shell_label}"

    local deluser_count
    deluser_count=$(grep -c '^ksmbd.deluser ' "${MOCK_COMMAND_LOG}" 2>/dev/null || true)
    if [ "${deluser_count}" -ne 1 ]; then
      fail "[${shell_label}] expected ksmbd.deluser to run exactly once on failure"
    fi

    [ -f "${expected}" ] || fail "[${shell_label}] archive should remain available despite SMB failure"

    rm -rf "${OUTPUT_DIR}"
  done
}

@test "rejects unsupported export mode" {
  for idx in "${!SHELL_MATRIX_PATHS[@]}"; do
    local shell_label="${SHELL_MATRIX_LABELS[$idx]}"
    local shell_path="${SHELL_MATRIX_PATHS[$idx]}"

    reset_overlay_fixture
    rm -rf "${OUTPUT_DIR}"
    mock_reset_command_log

    MOCK_BACKUP_SHELL="${shell_path}"
    mock_run_backup --overlay "${OVERLAY_DIR}" --output "${OUTPUT_DIR}" --export=nfs
    local run_status=$status
    local run_output="${output}"
    unset MOCK_BACKUP_SHELL

    if [ "${run_status}" -ne 64 ]; then
      fail "[${shell_label}] expected EX_USAGE (64), got ${run_status}: ${run_output}"
    fi

    assert_output_contains "${run_output}" "Неподдерживаемый режим экспорта: nfs" "${shell_label}"
    [ ! -d "${OUTPUT_DIR}" ] || fail "[${shell_label}] output directory should not be created on argument error"
  done
}

@test "fails when overlay directory missing" {
  for idx in "${!SHELL_MATRIX_PATHS[@]}"; do
    local shell_label="${SHELL_MATRIX_LABELS[$idx]}"
    local shell_path="${SHELL_MATRIX_PATHS[$idx]}"

    mock_reset_command_log

    local missing="${MOCK_WORKSPACE}/missing-overlay-${idx}"
    rm -rf "${missing}"

    MOCK_BACKUP_SHELL="${shell_path}"
    mock_run_backup --overlay "${missing}" --output "${OUTPUT_DIR}"
    local run_status=$status
    local run_output="${output}"
    unset MOCK_BACKUP_SHELL

    if [ "${run_status}" -ne 70 ]; then
      fail "[${shell_label}] expected failure when overlay is missing, got ${run_status}: ${run_output}"
    fi

    assert_output_contains "${run_output}" "Каталог для архивации не найден" "${shell_label}"
  done
}
