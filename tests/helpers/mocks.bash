#!/usr/bin/env bash

# Helper utilities for Bats tests.
# Provides a standard mocked environment with command stubs,
# temporary workspace management, and convenience assertions.

mock_setup() {
  if [[ -n "${MOCK_ENV_INITIALIZED-}" ]]; then
    return
  fi

  export MOCK_ENV_INITIALIZED=1

  export MOCK_PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  export MOCK_FIXTURES_DIR="${MOCK_PROJECT_ROOT}/tests/fixtures"
  export MOCK_TEMPLATE_BIN_DIR="${MOCK_PROJECT_ROOT}/tests/mocks/bin"

  export MOCK_WORKSPACE="${BATS_TEST_TMPDIR}/workspace"
  mkdir -p "${MOCK_WORKSPACE}"

  export MOCK_COMMAND_LOG="${BATS_TEST_TMPDIR}/command.log"
  : >"${MOCK_COMMAND_LOG}"

  export MOCK_COMMAND_HANDLER_DIR="${BATS_TEST_TMPDIR}/command-handlers"
  mkdir -p "${MOCK_COMMAND_HANDLER_DIR}"

  export MOCK_REAL_DATE="$(command -v date)"

  export MOCK_BIN_DIR="${BATS_TEST_TMPDIR}/mock-bin"
  mkdir -p "${MOCK_BIN_DIR}"

  local template
  for template in "${MOCK_TEMPLATE_BIN_DIR}"/*; do
    [[ -f "${template}" ]] || continue
    local name
    name="$(basename "${template}")"
    [[ "${name}" == "_mock" ]] && continue
    ln -s "${template}" "${MOCK_BIN_DIR}/${name}"
  done

  export MOCK_ORIGINAL_PATH="${PATH}"
  export PATH="${MOCK_BIN_DIR}:${PATH}"

  export MOCK_FAKE_ROOT="${BATS_TEST_TMPDIR}/fake-root"
  mkdir -p "${MOCK_FAKE_ROOT}"

  export MOCK_SMB_CLEANUP_DIR="${BATS_TEST_TMPDIR}/cleanup"
  mkdir -p "${MOCK_SMB_CLEANUP_DIR}"
}

mock_teardown() {
  if [[ -n "${MOCK_ORIGINAL_PATH-}" ]]; then
    PATH="${MOCK_ORIGINAL_PATH}"
  fi

  rm -rf "${MOCK_BIN_DIR-}"
  rm -rf "${MOCK_COMMAND_HANDLER_DIR-}"
  rm -rf "${MOCK_FAKE_ROOT-}"
  rm -rf "${MOCK_SMB_CLEANUP_DIR-}"
  rm -rf "${MOCK_WORKSPACE-}"
  rm -f "${MOCK_COMMAND_LOG-}"

  unset MOCK_ENV_INITIALIZED
  unset MOCK_PROJECT_ROOT
  unset MOCK_FIXTURES_DIR
  unset MOCK_TEMPLATE_BIN_DIR
  unset MOCK_WORKSPACE
  unset MOCK_COMMAND_LOG
  unset MOCK_COMMAND_HANDLER_DIR
  unset MOCK_BIN_DIR
  unset MOCK_ORIGINAL_PATH
  unset MOCK_FAKE_ROOT
  unset MOCK_SMB_CLEANUP_DIR
  unset OPENWRT_RELEASE_PATH
  unset KSMBD_INIT_SCRIPT
  unset SMB_CLEANUP_DIR
}

mock_reset_command_log() {
  : >"${MOCK_COMMAND_LOG}"
}

mock_disable_command() {
  local name="$1"
  rm -f "${MOCK_BIN_DIR}/${name}"
}

mock_enable_command() {
  local name="$1"
  local source_path="${MOCK_TEMPLATE_BIN_DIR}/${name}"
  [[ -f "${source_path}" ]] || return 1
  ln -sf "${source_path}" "${MOCK_BIN_DIR}/${name}"
}

mock_use_fake_root() {
  mkdir -p "${MOCK_FAKE_ROOT}/etc/init.d"
  export OPENWRT_RELEASE_PATH="${MOCK_FAKE_ROOT}/etc/openwrt_release"
  export KSMBD_INIT_SCRIPT="${MOCK_FAKE_ROOT}/etc/init.d/ksmbd"
  export SMB_CLEANUP_DIR="${MOCK_SMB_CLEANUP_DIR}"
}

mock_install_release_fixture() {
  local fixture="${1:-${MOCK_FIXTURES_DIR}/system/openwrt_release}"
  mkdir -p "$(dirname "${OPENWRT_RELEASE_PATH}")"
  cp "${fixture}" "${OPENWRT_RELEASE_PATH}"
}

mock_install_ksmbd_service() {
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
    } >> "$log"
fi
exit 0
EOF
  chmod +x "${KSMBD_INIT_SCRIPT}"
}

mock_backup_script() {
  printf '%s\n' "${MOCK_PROJECT_ROOT}/scripts/openwrt_full_backup"
}

mock_run_backup() {
  local script
  script="$(mock_backup_script)"
  (
    cd "${MOCK_WORKSPACE}"
    run env \
      OPENWRT_RELEASE_PATH="${OPENWRT_RELEASE_PATH-}" \
      KSMBD_INIT_SCRIPT="${KSMBD_INIT_SCRIPT-}" \
      SMB_CLEANUP_DIR="${SMB_CLEANUP_DIR-}" \
      MOCK_COMMAND_LOG="${MOCK_COMMAND_LOG}" \
      MOCK_COMMAND_HANDLER_DIR="${MOCK_COMMAND_HANDLER_DIR}" \
      PATH="${PATH}" \
      "${script}" "$@"
  )
}

mock_user_script() {
  printf '%s\n' "${MOCK_PROJECT_ROOT}/scripts/user_installed_packages"
}

mock_run_user_installed() {
  local script
  script="$(mock_user_script)"
  (
    cd "${MOCK_WORKSPACE}"
    run env PATH="${PATH}" "${script}" "$@"
  )
}

mock_assert_log_contains() {
  local phrase="$1"
  if ! grep -F -- "${phrase}" "${MOCK_COMMAND_LOG}" >/dev/null 2>&1; then
    fail "expected command log to contain: ${phrase}"
  fi
}

mock_assert_file_contains() {
  local file="$1"
  local phrase="$2"
  if ! grep -F -- "${phrase}" "${file}" >/dev/null 2>&1; then
    fail "expected ${file} to contain: ${phrase}"
  fi
}

assert_success() {
  if [[ "${status}" -ne 0 ]]; then
    fail "expected success, got ${status}: ${output}"
  fi
}

assert_status() {
  local expected="$1"
  if [[ "${status}" -ne "${expected}" ]]; then
    fail "expected status ${expected}, got ${status}: ${output}"
  fi
}

read_fixture() {
  local rel_path="$1"
  cat "${MOCK_FIXTURES_DIR}/${rel_path}"
}
