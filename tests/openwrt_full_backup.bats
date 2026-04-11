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

# Regex pattern to match any backup archive filename
# Usage: [[ "$output" =~ $ARCHIVE_FILENAME_REGEX ]]
ARCHIVE_FILENAME_REGEX='fullbackup_OpenWrt_[0-9]+\.[0-9]+\.[0-9]+_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}\.tar\.gz'

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
  # bats test_tags=uses_mocks
  if [[ "${USE_SYSTEM_TOOLS:-}" == "1" ]]; then
    skip "This test requires mocks (incompatible with USE_SYSTEM_TOOLS=1)"
  fi
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
      *" overlay") ;;
      *) fail "[${shell_label}] tar missing overlay directory: ${tar_line}" ;;
    esac

    if grep -F -- 'ksmbd' "${MOCK_COMMAND_LOG}" >/dev/null 2>&1; then
      local command_log_dump
      command_log_dump=$(cat "${MOCK_COMMAND_LOG}")
      fail "[${shell_label}] unexpected ksmbd invocation: ${command_log_dump}"
    fi

    # Check archive message with regex (any date)
    if ! printf '%s\n' "${run_output}" | grep -qE "Архив сохранён: .*${ARCHIVE_FILENAME_REGEX}"; then
      fail "[${shell_label}] expected archive message with any date: ${run_output}"
    fi
    # Check scp hint with regex (any date)
    if ! printf '%s\n' "${run_output}" | grep -qE "scp root@mock-router:.*${ARCHIVE_FILENAME_REGEX}"; then
      fail "[${shell_label}] expected scp hint with any date: ${run_output}"
    fi

    rm -rf "${OUTPUT_DIR}"
  done
}

@test "dry-run skips tar invocation across shells" {
  # bats test_tags=uses_mocks
  if [[ "${USE_SYSTEM_TOOLS:-}" == "1" ]]; then
    skip "This test requires mocks (incompatible with USE_SYSTEM_TOOLS=1)"
  fi
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
    # Check dry-run mentions archive path with regex (any date)
    if ! printf '%s\n' "${run_output}" | grep -qE "${ARCHIVE_FILENAME_REGEX}"; then
      fail "[${shell_label}] expected archive path with any date in dry-run: ${run_output}"
    fi

    if grep -q '^tar ' "${MOCK_COMMAND_LOG}"; then
      fail "[${shell_label}] tar should not be executed during dry-run"
    fi
  done
}

@test "fails and removes partial archive when tar fails" {
  # bats test_tags=uses_mocks
  if [[ "${USE_SYSTEM_TOOLS:-}" == "1" ]]; then
    skip "This test requires mocks (incompatible with USE_SYSTEM_TOOLS=1)"
  fi
  # Force mock PATH for this test (tar must fail)
  export PATH="${MOCK_BIN_DIR}:${PATH}"
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
    [ ! -f "${expected}" ] || fail "[${shell_label}] archive should not exist after tar failure"

    rm -rf "${OUTPUT_DIR}"
  done
}

@test "handles tar failure gracefully" {
  # bats test_tags=uses_mocks
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
    [ ! -f "${expected}" ] || fail "[${shell_label}] archive should not exist after tar failure"

    rm -rf "${OUTPUT_DIR}"
  done
}

@test "rejects unsupported export mode" {
  # bats test_tags=uses_mocks
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
