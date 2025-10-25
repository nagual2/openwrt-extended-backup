#!/usr/bin/env bats

load 'helpers/mocks'

setup() {
  mock_setup
}

teardown() {
  mock_teardown
}

@test "openwrt_full_backup prints usage with --help" {
  run "${MOCK_PROJECT_ROOT}/openwrt_full_backup" --help
  assert_success
  [[ "${output}" == *"Использование: openwrt_full_backup"* ]]
}

@test "openwrt_full_backup refuses to run without openwrt_release" {
  mock_use_fake_root
  # do not install the release fixture

  mock_reset_command_log
  mock_run_backup --out-dir "${MOCK_WORKSPACE}/out"

  assert_status 69
  [[ "${output}" == *"Не найден файл описания прошивки"* ]]
}

@test "openwrt_full_backup creates archive via tar in SCP mode" {
  mock_use_fake_root
  mock_install_release_fixture
  mock_reset_command_log

  out_dir="${MOCK_WORKSPACE}/out"
  mkdir -p "${out_dir}"

  mock_run_backup --out-dir "${out_dir}"

  assert_success
  tar_line=$(grep '^tar ' "${MOCK_COMMAND_LOG}" | tail -n 1)
  [[ "${tar_line}" == *"/overlay"* ]]

  archive_count=$(find "${out_dir}" -type f -name 'fullbackup_*' | wc -l)
  [[ "${archive_count}" -eq 1 ]]
  [[ "${output}" == *"Архив сохранён"* ]]
}

@test "openwrt_full_backup reports missing ksmbd utilities" {
  mock_use_fake_root
  mock_install_release_fixture
  mock_disable_command 'ksmbd.adduser'

  mock_run_backup --export=smb --out-dir "${MOCK_WORKSPACE}/out"

  assert_status 69
  [[ "${output}" == *"Требуемая утилита 'ksmbd.adduser' недоступна"* ]]
}

@test "openwrt_full_backup creates SMB cleanup hooks" {
  mock_use_fake_root
  mock_install_release_fixture
  mock_install_ksmbd_service
  mock_reset_command_log

  out_dir="${MOCK_WORKSPACE}/out"
  mkdir -p "${out_dir}"

  mock_run_backup --export=smb --out-dir "${out_dir}"

  assert_success

  share_hook="${SMB_CLEANUP_DIR}/remove_ksmbd_share.sh"
  user_hook="${SMB_CLEANUP_DIR}/remove_ksmbd_user.sh"

  [[ -x "${share_hook}" ]]
  [[ -x "${user_hook}" ]]
  [[ -f "${SMB_CLEANUP_DIR}/README.txt" ]]

  mock_assert_file_contains "${share_hook}" "owrt_archive"
  mock_assert_file_contains "${share_hook}" "${KSMBD_INIT_SCRIPT}"
  mock_assert_file_contains "${user_hook}" "owrt_backup"
}

@test "openwrt_full_backup propagates non-zero exit codes from mocks" {
  mock_use_fake_root
  mock_install_release_fixture
  mock_install_ksmbd_service

  export MOCK_FAIL_KSMBD_ADDUSER=1
  export MOCK_FAIL_KSMBD_ADDUSER_EXIT_CODE=13
  export MOCK_FAIL_KSMBD_ADDUSER_MESSAGE='mock ksmbd failure'

  mock_run_backup --export=smb --out-dir "${MOCK_WORKSPACE}/out"

  assert_status 13
  [[ "${output}" == *"mock ksmbd failure"* ]]
}
