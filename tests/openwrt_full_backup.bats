#!/usr/bin/env bats

# Coverage: Negative and edge-path behavior for openwrt_full_backup including
# tar failures, missing overlay handling, ksmbd user creation errors, and
# unwritable output directories. These tests increase error-path coverage.

load 'test_helper'

setup_file() {
    PROJECT_ROOT=$(project_root)
    BACKUP_SCRIPT="$PROJECT_ROOT/scripts/openwrt_full_backup"
    BACKUP_FIXTURES="$PROJECT_ROOT/tests/fixtures/openwrt_full_backup"
    REAL_DATE=$(command -v date)
    REAL_UNAME=$(command -v uname)
}

setup() {
    PATH_ORIG=$PATH
    LOCKED_BASE=''
    STUB_DIR="$BATS_TEST_TMPDIR/stub-bin"
    rm -rf "$STUB_DIR"
    mkdir -p "$STUB_DIR"
    PATH="$STUB_DIR:$PATH_ORIG"
    export PATH
    TMP_OUT_DIR="$BATS_TEST_TMPDIR/out"
    mkdir -p "$TMP_OUT_DIR"
}

teardown() {
    PATH=$PATH_ORIG
    if [ -n "${LOCKED_BASE:-}" ] && [ -d "$LOCKED_BASE" ]; then
        chmod 700 "$LOCKED_BASE" 2>/dev/null || true
    fi
}

stub_datetime() {
    cat >"$STUB_DIR/date" <<EOF
#!/bin/sh
case "\$1" in
    '+%Y-%m-%d_%H-%M-%S')
        printf '2024-01-02_03-04-05\n'
        ;;
    '+%Y-%m-%d %H:%M:%S')
        printf '2024-01-02 03:04:05\n'
        ;;
    '+%H%M%S')
        printf '030405\n'
        ;;
    *)
        exec "$REAL_DATE" "\$@"
        ;;
esac
EOF
    chmod +x "$STUB_DIR/date"

    cat >"$STUB_DIR/uname" <<EOF
#!/bin/sh
if [ "\$#" -eq 0 ] || [ "\$1" = '-n' ]; then
    printf 'router-host\n'
    exit 0
fi
exec "$REAL_UNAME" "\$@"
EOF
    chmod +x "$STUB_DIR/uname"
}

stub_tar() {
    cat >"$STUB_DIR/tar" <<'EOF'
#!/bin/sh
outfile=''
need_next=0
for arg in "$@"; do
    if [ "$need_next" -eq 1 ]; then
        outfile=$arg
        break
    fi
    case "$arg" in
        -f)
            need_next=1
            continue
            ;;
        -*f*)
            need_next=1
            continue
            ;;
    esac
    if [ "${outfile}" = '' ] && [ "${arg#-}" = "$arg" ]; then
        outfile=$arg
        break
    fi
done
if [ -z "$outfile" ] && [ "$#" -ge 2 ]; then
    outfile=$2
fi
status=${FAKE_TAR_STATUS:-0}
if [ "$status" -ne 0 ]; then
    if [ -n "${FAKE_TAR_MESSAGE:-}" ]; then
        printf '%s\n' "$FAKE_TAR_MESSAGE" >&2
    fi
    exit "$status"
fi
if [ -n "$outfile" ]; then
    mkdir -p "$(dirname "$outfile")"
    : >"$outfile"
fi
exit 0
EOF
    chmod +x "$STUB_DIR/tar"
}

stub_uci() {
    cat >"$STUB_DIR/uci" <<'EOF'
#!/bin/sh
if [ "${1:-}" = '-q' ]; then
    shift
fi
cmd=${1:-}
case "$cmd" in
    add|set|commit|delete)
        exit 0
        ;;
    show)
        exit 0
        ;;
    get)
        exit 1
        ;;
    *)
        exit 0
        ;;
esac
EOF
    chmod +x "$STUB_DIR/uci"
}

@test "tar failure aborts the backup with a fatal error" {
    stub_datetime
    stub_tar
    local out_dir="$TMP_OUT_DIR/local"
    mkdir -p "$out_dir"
    run env FAKE_TAR_STATUS=2 \
        FAKE_TAR_MESSAGE='tar: simulated failure' \
        "$BACKUP_SCRIPT" --out-dir "$out_dir"
    assert_exit_code 70
    assert_normalized_equals "$stderr" \
        "$BACKUP_FIXTURES/expected-tar-failure.stderr" \
        "$out_dir" '${TMP_OUT_DIR}'
}

@test "missing overlay directory surfaces tar error output" {
    stub_datetime
    stub_tar
    local out_dir="$TMP_OUT_DIR/missing"
    mkdir -p "$out_dir"
    run env FAKE_TAR_STATUS=2 \
        FAKE_TAR_MESSAGE='tar: /overlay: Cannot open: No such file or directory' \
        "$BACKUP_SCRIPT" --out-dir "$out_dir"
    assert_exit_code 70
    assert_normalized_equals "$stderr" \
        "$BACKUP_FIXTURES/expected-missing-overlay.stderr" \
        "$out_dir" '${TMP_OUT_DIR}'
}

@test "permission denied output directory is reported" {
    stub_datetime
    local base="$BATS_TEST_TMPDIR/locked"
    mkdir -p "$base"
    chmod 500 "$base"
    LOCKED_BASE="$base"
    local out_dir="$base/nested"
    run "$BACKUP_SCRIPT" --out-dir "$out_dir"
    assert_exit_code 70
    assert_normalized_equals "$stderr" \
        "$BACKUP_FIXTURES/expected-permission-denied.stderr" \
        "$out_dir" '${TMP_OUT_DIR}'
}

@test "ksmbd user provisioning failure stops SMB export" {
    stub_datetime
    stub_tar
    stub_uci

    cat >"$STUB_DIR/ksmbd.adduser" <<'EOF'
#!/bin/sh
printf 'ksmbd.adduser: simulated failure\n' >&2
exit 1
EOF
    chmod +x "$STUB_DIR/ksmbd.adduser"

    local init_stub="$BATS_TEST_TMPDIR/ksmbd-init"
    cat >"$init_stub" <<'EOF'
#!/bin/sh
exit 0
EOF
    chmod +x "$init_stub"

    local out_dir="$TMP_OUT_DIR/smb"
    mkdir -p "$out_dir"
    local archive="${out_dir}/fullbackup_router-host_2024-01-02_03-04-05.tar.gz"

    run env KSMBD_INIT_SCRIPT="$init_stub" "$BACKUP_SCRIPT" --export=smb --out-dir "$out_dir"
    assert_failure 1
    [ -f "$archive" ]
    assert_normalized_equals "$stderr" \
        "$BACKUP_FIXTURES/expected-ksmbd-user-error.stderr" \
        "$out_dir" '${TMP_OUT_DIR}'
}
