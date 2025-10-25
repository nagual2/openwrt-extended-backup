#!/bin/sh
# shellcheck shell=sh

set -eu

if ! command -v git >/dev/null 2>&1; then
    printf 'git is required to list shell scripts.\n' >&2
    exit 127
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT" || exit 1

git ls-files | while IFS= read -r path; do
    if [ ! -f "$path" ]; then
        continue
    fi

    case "$path" in
        */.git/*)
            continue
            ;;
    esac

    if [ -x "$path" ]; then
        printf '%s\n' "$path"
        continue
    fi

    case "$path" in
        *.sh)
            printf '%s\n' "$path"
            ;;
    esac
done | sort -u
