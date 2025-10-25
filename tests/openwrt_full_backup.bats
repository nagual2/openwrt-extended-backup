#!/usr/bin/env bats

setup() {
    PROJECT_ROOT=$(cd "$BATS_TEST_DIRNAME/.." 2>/dev/null && pwd)
    SCRIPT_PATH="$PROJECT_ROOT/scripts/openwrt_full_backup"
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
}
