#!/usr/bin/env bats

setup() {
    PROJECT_ROOT=$(cd "$BATS_TEST_DIRNAME/.." 2>/dev/null && pwd)
    SCRIPT_PATH="$PROJECT_ROOT/scripts/openwrt_full_backup"
<<<<<<< HEAD

    PATH_ORIG=$PATH
    TEST_ROOT=$(mktemp -d)
    BIN_DIR="$TEST_ROOT/bin"
    mkdir -p "$BIN_DIR"
    export PATH="$BIN_DIR:$PATH_ORIG"

    REAL_DATE=$(command -v date)
    cat >"$BIN_DIR/date" <<EOF
#!/bin/sh
if [ "\$#" -eq 0 ]; then
    exec "$REAL_DATE"
fi
case "\$1" in
    '+%Y-%m-%d %H:%M:%S')
        printf '2024-01-01 00:00:00\n'
        ;;
    '+%Y-%m-%d_%H-%M-%S')
        printf '2024-01-01_00-00-00\n'
        ;;
    '+%H%M%S')
        printf '000000\n'
        ;;
    *)
        exec "$REAL_DATE" "\$@"
        ;;
esac
EOF
    chmod +x "$BIN_DIR/date"

    REAL_UNAME=$(command -v uname)
    cat >"$BIN_DIR/uname" <<EOF
#!/bin/sh
if [ "\$#" -gt 0 ]; then
    case "\$1" in
        -n)
            printf 'TestRouter\n'
            exit 0
            ;;
    esac
fi
exec "$REAL_UNAME" "\$@"
EOF
    chmod +x "$BIN_DIR/uname"

    cat >"$BIN_DIR/upload_stub" <<'EOF'
#!/bin/sh
set -eu
command_name=$(basename "$0")
log=${MOCK_UPLOAD_LOG:-}
if [ -n "$log" ]; then
    printf '%s %s\n' "$command_name" "$*" >>"$log"
fi

batch=''
if [ "$command_name" = "sftp" ]; then
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -b)
                shift
                if [ "$#" -gt 0 ]; then
                    batch=$1
                fi
                ;;
        esac
        shift || break
    done
    if [ -n "$batch" ] && [ -n "${MOCK_SFTP_BATCH_LOG:-}" ] && [ -f "$batch" ]; then
        cat "$batch" >"${MOCK_SFTP_BATCH_LOG}"
    fi
fi

fail_limit=${MOCK_UPLOAD_FAIL_LIMIT:-0}
fail_code=${MOCK_UPLOAD_FAIL_CODE:-1}
if [ "$fail_limit" -gt 0 ]; then
    counter_file=${MOCK_UPLOAD_FAIL_FILE:-"${TMPDIR:-/tmp}/mock-upload-fail-count"}
    count=$(cat "$counter_file" 2>/dev/null || printf '0')
    count=$((count + 1))
    printf '%s\n' "$count" >"$counter_file"
    if [ "$count" -le "$fail_limit" ]; then
        exit "$fail_code"
    fi
fi

exit ${MOCK_UPLOAD_EXIT_CODE:-0}
EOF
    chmod +x "$BIN_DIR/upload_stub"
    ln -s upload_stub "$BIN_DIR/scp"
    ln -s upload_stub "$BIN_DIR/sftp"

    OVERLAY_DIR="$TEST_ROOT/overlay"
    mkdir -p "$OVERLAY_DIR"
    printf 'example-data' >"$OVERLAY_DIR/sample.txt"
    export OVERLAY_SOURCE="$OVERLAY_DIR"

    OUT_DIR="$TEST_ROOT/out"
    mkdir -p "$OUT_DIR"
    EXPECTED_ARCHIVE="$OUT_DIR/fullbackup_TestRouter_2024-01-01_00-00-00.tar.gz"
}

teardown() {
    PATH=$PATH_ORIG
    rm -rf "$TEST_ROOT"
    unset MOCK_UPLOAD_LOG MOCK_SFTP_BATCH_LOG MOCK_UPLOAD_FAIL_LIMIT \
        MOCK_UPLOAD_FAIL_FILE MOCK_UPLOAD_FAIL_CODE MOCK_UPLOAD_EXIT_CODE
}

@test "scp upload invokes scp with provided options" {
    identity="$TEST_ROOT/id_ed25519"
    known_hosts="$TEST_ROOT/known_hosts"
    touch "$identity" "$known_hosts"

    export MOCK_UPLOAD_LOG="$TEST_ROOT/scp.log"

    run "$SCRIPT_PATH" \
        --upload "scp://backup@example.com:/remote/archive.tar.gz" \
        --identity "$identity" \
        --known-hosts "$known_hosts" \
        --port 2022 \
        --retry 1 \
        --out-dir "$OUT_DIR" \
        --export=scp

    [ "$status" -eq 0 ]
    [ -f "$EXPECTED_ARCHIVE" ]

    command_logged=$(cat "$MOCK_UPLOAD_LOG")
    [[ "$command_logged" == scp* ]]
    [[ "$command_logged" == *"-P 2022"* ]]
    [[ "$command_logged" == *"-i $identity"* ]]
    [[ "$command_logged" == *"UserKnownHostsFile=$known_hosts"* ]]
    [[ "$command_logged" == *"StrictHostKeyChecking=yes"* ]]
    [[ "$command_logged" == *"$EXPECTED_ARCHIVE"* ]]
    [[ "$command_logged" == *"backup@example.com:'/remote/archive.tar.gz'"* ]]
}

@test "sftp upload writes batch file" {
    export MOCK_UPLOAD_LOG="$TEST_ROOT/sftp.log"
    export MOCK_SFTP_BATCH_LOG="$TEST_ROOT/batch.log"

    run "$SCRIPT_PATH" \
        --upload "sftp://backup@example.com:/remote/archive.tar.gz" \
        --out-dir "$OUT_DIR" \
        --export=local

    [ "$status" -eq 0 ]
    [ -f "$EXPECTED_ARCHIVE" ]

    command_logged=$(cat "$MOCK_UPLOAD_LOG")
    [[ "$command_logged" == sftp* ]]
    [[ "$command_logged" == *"-b"* ]]
    [[ "$command_logged" == *"backup@example.com"* ]]

    read -r batch_line <"$MOCK_SFTP_BATCH_LOG"
    expected_line="put \"$EXPECTED_ARCHIVE\" \"/remote/archive.tar.gz\""
    [ "$batch_line" = "$expected_line" ]
}

@test "retry succeeds after transient failure" {
    export MOCK_UPLOAD_LOG="$TEST_ROOT/retry.log"
    export MOCK_UPLOAD_FAIL_LIMIT=1
    export MOCK_UPLOAD_FAIL_FILE="$TEST_ROOT/retry-count"

    run "$SCRIPT_PATH" \
        --upload "scp://backup@example.com:/remote/archive.tar.gz" \
        --out-dir "$OUT_DIR" \
        --retry 2 \
        --export=local

    [ "$status" -eq 0 ]
    [ -f "$EXPECTED_ARCHIVE" ]

    attempt_count=$(wc -l <"$MOCK_UPLOAD_LOG")
    [ "$attempt_count" -eq 2 ]
}

@test "upload failure propagates exit status" {
    export MOCK_UPLOAD_LOG="$TEST_ROOT/fail.log"
    export MOCK_UPLOAD_FAIL_LIMIT=5
    export MOCK_UPLOAD_FAIL_FILE="$TEST_ROOT/fail-count"
    export MOCK_UPLOAD_FAIL_CODE=7

    run "$SCRIPT_PATH" \
        --upload "scp://backup@example.com:/remote/archive.tar.gz" \
        --out-dir "$OUT_DIR" \
        --retry 2 \
        --export=local

    [ "$status" -eq 7 ]

    attempt_count=$(wc -l <"$MOCK_UPLOAD_LOG")
    [ "$attempt_count" -eq 2 ]
}

@test "dry-run prints planned upload command" {
    export MOCK_UPLOAD_LOG="$TEST_ROOT/dry.log"

    run "$SCRIPT_PATH" \
        --upload "scp://backup@example.com:/remote/archive.tar.gz" \
        --out-dir "$OUT_DIR" \
        --export=scp \
        --dry-run

    [ "$status" -eq 0 ]
    [ ! -f "$EXPECTED_ARCHIVE" ]
    if [ -e "$MOCK_UPLOAD_LOG" ]; then
        [ ! -s "$MOCK_UPLOAD_LOG" ]
    fi

    [[ "$output" == *"Режим dry-run: готовая команда SCP"* ]]
    [[ "$output" == *"/remote/archive.tar.gz"* ]]
=======
    MOCK_BIN="$BATS_TEST_TMPDIR/bin"
    mkdir -p "$MOCK_BIN"

    cat >"$MOCK_BIN/tar" <<EOF
#!/bin/sh
touch "$BATS_TEST_TMPDIR/tar-invoked"
printf 'mock tar executed\n' >&2
exit 1
EOF
    chmod +x "$MOCK_BIN/tar"

    PATH_ORIGINAL=$PATH
    PATH="$MOCK_BIN:$PATH_ORIGINAL"
    export PATH

    rm -f "$BATS_TEST_TMPDIR/tar-invoked"
}

teardown() {
    PATH=$PATH_ORIGINAL
    export PATH
}

@test "usage mentions dry-run and output options" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--output PATH"* ]]
    [[ "$output" == *"-n, --dry-run"* ]]
}

@test "dry-run flag avoids side effects" {
    rm -f "$BATS_TEST_TMPDIR/tar-invoked"
    output_dir="$BATS_TEST_TMPDIR/custom-output"
    run "$SCRIPT_PATH" -n --output "$output_dir"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Режим dry-run: действия выполняются без побочных эффектов"* ]]
    [[ "$output" == *"Режим dry-run: архив не создавался"* ]]
    [[ "$output" == *"$output_dir"* ]]
    [ ! -f "$BATS_TEST_TMPDIR/tar-invoked" ]
    [ ! -d "$output_dir" ]
}

@test "DRY_RUN environment variable enables dry-run" {
    rm -f "$BATS_TEST_TMPDIR/tar-invoked"
    output_dir="$BATS_TEST_TMPDIR/env-output"
    run env DRY_RUN=true "$SCRIPT_PATH" --output "$output_dir"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Режим dry-run: архив не создавался"* ]]
    [ ! -f "$BATS_TEST_TMPDIR/tar-invoked" ]
    [ ! -d "$output_dir" ]
}

@test "--output accepts relative paths" {
    rm -f "$BATS_TEST_TMPDIR/tar-invoked"
    rm -rf relative-dir
    expected="$(pwd)/relative-dir"
    run env DRY_RUN=1 "$SCRIPT_PATH" --output relative-dir
    [ "$status" -eq 0 ]
    [[ "$output" == *"$expected"* ]]
    [ ! -f "$BATS_TEST_TMPDIR/tar-invoked" ]
    [ ! -d "$expected" ]
>>>>>>> origin/feat-5-backup-dry-run-output-tests
}
