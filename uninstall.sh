#!/bin/sh
# shellcheck shell=sh

set -eu

PROGRAM=$(basename "$0")

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

remove_script() {
    target=$1

    if [ -e "$target" ]; then
        if rm -f "$target"; then
            printf 'Removed %s\n' "$target"
        else
            printf '%s: failed to remove %s\n' "$PROGRAM" "$target" >&2
            exit 1
        fi
    fi
}

remove_script "$BIN_DIR/openwrt_full_backup"
remove_script "$BIN_DIR/user_installed_packages"
