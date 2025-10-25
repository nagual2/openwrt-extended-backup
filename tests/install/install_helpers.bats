#!/usr/bin/env bats

setup() {
    PROJECT_ROOT=$(cd "$BATS_TEST_DIRNAME/../.." 2>/dev/null && pwd)
    PREFIX=$(mktemp -d "${BATS_TMPDIR:-/tmp}/owrt-install.XXXXXX")
    BIN_DIR="$PREFIX/bin"
}

teardown() {
    if [ -n "${PREFIX-}" ] && [ -d "$PREFIX" ]; then
        rm -rf "$PREFIX"
    fi
}

@test "install.sh installs scripts into custom prefix" {
    run env PREFIX="$PREFIX" sh "$PROJECT_ROOT/install.sh"
    [ "$status" -eq 0 ]

    [ -x "$BIN_DIR/openwrt_full_backup" ]
    [ -x "$BIN_DIR/user_installed_packages" ]

    run diff "$PROJECT_ROOT/scripts/openwrt_full_backup" "$BIN_DIR/openwrt_full_backup"
    [ "$status" -eq 0 ]

    run diff "$PROJECT_ROOT/scripts/user_installed_packages" "$BIN_DIR/user_installed_packages"
    [ "$status" -eq 0 ]

    run "$BIN_DIR/openwrt_full_backup" --version
    [ "$status" -eq 0 ]
    [[ "$output" == openwrt_full_backup* ]]
}

@test "uninstall.sh removes installed scripts" {
    env PREFIX="$PREFIX" sh "$PROJECT_ROOT/install.sh"

    run env PREFIX="$PREFIX" sh "$PROJECT_ROOT/uninstall.sh"
    [ "$status" -eq 0 ]

    [ ! -e "$BIN_DIR/openwrt_full_backup" ]
    [ ! -e "$BIN_DIR/user_installed_packages" ]
}

@test "uninstall.sh succeeds when nothing is installed" {
    run env PREFIX="$PREFIX" sh "$PROJECT_ROOT/uninstall.sh"
    [ "$status" -eq 0 ]
}
