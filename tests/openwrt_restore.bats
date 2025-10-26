#!/usr/bin/env bats

setup() {
    PROJECT_ROOT=$(cd "$(dirname "$BATS_TEST_FILENAME")/.." 2>/dev/null && pwd)
    SCRIPT_PATH="$PROJECT_ROOT/scripts/openwrt_restore"
    TMPDIR=$(mktemp -d /tmp/openwrt-restore-test.XXXXXX)
    export TMPDIR

    MOCK_BIN="$TMPDIR/bin"
    mkdir -p "$MOCK_BIN"
    PATH="$MOCK_BIN:$PATH"
    export PATH
}

teardown() {
    rm -rf "$TMPDIR"
}

create_archive_with_file() {
    archive_path=$1
    content=$2

    source_dir=$(mktemp -d "$TMPDIR/source.XXXXXX")
    mkdir -p "$source_dir/overlay/upper/etc/config"
    printf '%s\n' "$content" >"$source_dir/overlay/upper/etc/config/system"
    tar -czf "$archive_path" -C "$source_dir" overlay
}

@test "restores overlay and runs provided package script" {
    archive="$TMPDIR/fullbackup.tar.gz"
    create_archive_with_file "$archive" 'restored-config'
    sha256sum "$archive" >"$archive.sha256"

    overlay_target="$TMPDIR/overlay-target"
    mkdir -p "$overlay_target/upper/etc/config"
    printf 'old-config\n' >"$overlay_target/upper/etc/config/system"

    packages_script="$TMPDIR/packages.sh"
    cat <<EOF >"$packages_script"
#!/bin/sh
echo "package-script" >> "$TMPDIR/packages.log"
EOF
    chmod +x "$packages_script"

    run "$SCRIPT_PATH" --archive "$archive" --packages "$packages_script" --overlay "$overlay_target" --no-reboot --force
    [ "$status" -eq 0 ]

    run cat "$overlay_target/upper/etc/config/system"
    [ "$status" -eq 0 ]
    [ "$output" = 'restored-config' ]

    [ -f "$TMPDIR/packages.log" ]

    snapshot_dir="$TMPDIR/openwrt-restore-snapshots"
    [ -d "$snapshot_dir" ]
    find "$snapshot_dir" -maxdepth 1 -type f -name 'overlay-snapshot-*.tar.gz' | grep -q '.'
}

@test "fails when archive is missing" {
    overlay_target="$TMPDIR/overlay-target"
    mkdir -p "$overlay_target"

    run "$SCRIPT_PATH" --archive "$TMPDIR/missing.tar.gz" --overlay "$overlay_target" --no-reboot --force
    [ "$status" -ne 0 ]
    echo "$output" | grep -q 'Архив недоступен для чтения'
}

@test "dry-run leaves overlay untouched" {
    archive="$TMPDIR/fullbackup.tar.gz"
    create_archive_with_file "$archive" 'new-config'

    overlay_target="$TMPDIR/overlay-target"
    mkdir -p "$overlay_target/upper/etc/config"
    printf 'old-config\n' >"$overlay_target/upper/etc/config/system"

    run "$SCRIPT_PATH" --dry-run --archive "$archive" --overlay "$overlay_target" --no-reboot --force
    [ "$status" -eq 0 ]

    run cat "$overlay_target/upper/etc/config/system"
    [ "$status" -eq 0 ]
    [ "$output" = 'old-config' ]

    [ ! -d "$TMPDIR/openwrt-restore-snapshots" ]
}

@test "runs user_installed_packages helper when packages not provided" {
    mock_helper="$MOCK_BIN/user_installed_packages"
    cat <<'EOF' >"$mock_helper"
#!/bin/sh
LOG_FILE="${TMPDIR%/}/auto-packages.log"
cat <<EOS
#!/bin/sh
echo "auto-run" >> "$LOG_FILE"
EOS
EOF
    chmod +x "$mock_helper"

    archive="$TMPDIR/fullbackup.tar.gz"
    create_archive_with_file "$archive" 'auto-config'

    overlay_target="$TMPDIR/overlay-target"
    mkdir -p "$overlay_target/upper/etc/config"

    run "$SCRIPT_PATH" --archive "$archive" --overlay "$overlay_target" --no-reboot --force
    [ "$status" -eq 0 ]

    [ -f "$TMPDIR/auto-packages.log" ]
}

@test "cleans temporary data on extraction failure" {
    archive="$TMPDIR/broken.tar.gz"
    source_dir=$(mktemp -d "$TMPDIR/source-bad.XXXXXX")
    printf 'readme' >"$source_dir/README"
    tar -czf "$archive" -C "$source_dir" README

    overlay_target="$TMPDIR/overlay-target"
    mkdir -p "$overlay_target"

    run "$SCRIPT_PATH" --archive "$archive" --overlay "$overlay_target" --no-reboot --force
    [ "$status" -ne 0 ]

    leftovers=$(find "$TMPDIR" -mindepth 1 -maxdepth 1 -type d -name 'openwrt-restore.*' | wc -l | tr -d ' ')
    [ "$leftovers" -eq 0 ]
}
