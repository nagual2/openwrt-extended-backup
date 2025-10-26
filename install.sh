#!/bin/sh
# shellcheck shell=sh

set -eu

PROGRAM=$(basename "$0")
SCRIPT_PATH=$0

case "$SCRIPT_PATH" in
    */*)
        SCRIPT_SOURCE=$(dirname "$SCRIPT_PATH")
        ;;
    *)
        LOOKUP=$(command -v -- "$SCRIPT_PATH" 2>/dev/null || printf '')
        if [ -n "$LOOKUP" ]; then
            SCRIPT_SOURCE=$(dirname "$LOOKUP")
        else
            SCRIPT_SOURCE='.'
        fi
        ;;
esac

if ! PROJECT_ROOT=$(cd "$SCRIPT_SOURCE" 2>/dev/null && pwd); then
    printf '%s: unable to determine project directory\n' "$PROGRAM" >&2
    exit 1
fi

PREFIX=${PREFIX:-/usr/local}
if [ -z "$PREFIX" ]; then
    printf '%s: PREFIX must not be empty\n' "$PROGRAM" >&2
    exit 1
fi

case "$PREFIX" in
    /*) ;;
    *)
        printf '%s: PREFIX must be an absolute path\n' "$PROGRAM" >&2
        exit 1
        ;;
esac

BIN_DIR=${BINDIR:-"$PREFIX/bin"}
if [ -z "$BIN_DIR" ]; then
    printf '%s: BINDIR must not be empty\n' "$PROGRAM" >&2
    exit 1
fi

case "$BIN_DIR" in
    /*) ;;
    *)
        printf '%s: BINDIR must be an absolute path\n' "$PROGRAM" >&2
        exit 1
        ;;
esac

if ! mkdir -p "$BIN_DIR"; then
    printf '%s: failed to create directory: %s\n' "$PROGRAM" "$BIN_DIR" >&2
    exit 1
fi

install_script() {
    src=$1
    dest=$2

    if [ ! -f "$src" ]; then
        printf '%s: source script not found: %s\n' "$PROGRAM" "$src" >&2
        exit 1
    fi

    if ! cp "$src" "$dest"; then
        printf '%s: failed to copy %s to %s\n' "$PROGRAM" "$src" "$dest" >&2
        exit 1
    fi

    if ! chmod 0755 "$dest"; then
        printf '%s: failed to set permissions on %s\n' "$PROGRAM" "$dest" >&2
        exit 1
    fi
}

install_script "$PROJECT_ROOT/scripts/openwrt_full_backup" "$BIN_DIR/openwrt_full_backup"
install_script "$PROJECT_ROOT/scripts/user_installed_packages" "$BIN_DIR/user_installed_packages"

printf 'Installed openwrt_full_backup to %s\n' "$BIN_DIR/openwrt_full_backup"
printf 'Installed user_installed_packages to %s\n' "$BIN_DIR/user_installed_packages"
