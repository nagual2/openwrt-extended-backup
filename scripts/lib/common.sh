#!/bin/sh
# shellcheck shell=sh

# Common helper library for OpenWrt backup utilities.
# Provides logging, error handling, temporary workspace management,
# environment detection helpers, and shared CLI utilities.

set -eu

# Prevent re-initialisation when sourced multiple times.
if [ "${COMMON_LIB_INITIALIZED-0}" -eq 1 ]; then
    return 0
fi
COMMON_LIB_INITIALIZED=1

# Standard exit codes (BSD sysexits) with sensible defaults.
: "${EX_OK:=0}"
: "${EX_USAGE:=64}"
: "${EX_UNAVAILABLE:=69}"
: "${EX_SOFTWARE:=70}"

# Default logging level: 0=quiet, 1=info, 2=debug.
if [ -z "${LOG_LEVEL+x}" ]; then
    LOG_LEVEL=1
fi

COMMON_PROGRAM=''
COMMON_VERSION=''
COMMON_SCRIPT_DIR=''
COMMON_PROJECT_ROOT=''
COMMON_TMPDIR=''
COMMON_CLEANUP_FUNCS=''
COMMON_CLEANUP_DONE=0

common_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

common_log_emit() {
    threshold=$1
    level=$2
    shift 2

    if [ "$level" = 'ERROR' ]; then
        should_log=1
    elif [ "$LOG_LEVEL" -ge "$threshold" ]; then
        should_log=1
    else
        should_log=0
    fi

    if [ "$should_log" -ne 1 ]; then
        return 0
    fi

    ts=$(common_timestamp)
    if [ "$#" -gt 0 ]; then
        printf '%s %s %s\n' "$ts" "$level" "$*" >&2
    else
        printf '%s %s\n' "$ts" "$level" >&2
    fi
}

log_info() {
    common_log_emit 1 'INFO' "$@"
}

log_warn() {
    common_log_emit 0 'WARN' "$@"
}

log_error() {
    common_log_emit 0 'ERROR' "$@"
}

log_debug() {
    common_log_emit 2 'DEBUG' "$@"
}

die() {
    message=$1
    code=${2:-1}
    log_error "$message"
    exit "$code"
}

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        die "Требуемая утилита '$1' недоступна" "$EX_UNAVAILABLE"
    fi
}

common_add_cleanup() {
    entry=$1
    if [ -z "$entry" ]; then
        return 0
    fi
    if [ -z "$COMMON_CLEANUP_FUNCS" ]; then
        COMMON_CLEANUP_FUNCS=$entry
    else
        COMMON_CLEANUP_FUNCS="$COMMON_CLEANUP_FUNCS $entry"
    fi
    return 0
}

common_cleanup_tmpdir() {
    if [ -n "$COMMON_TMPDIR" ] && [ -d "$COMMON_TMPDIR" ]; then
        rm -rf "$COMMON_TMPDIR"
    fi
}

common_cleanup() {
    status=$1

    if [ "$COMMON_CLEANUP_DONE" -eq 1 ]; then
        exit "$status"
    fi
    COMMON_CLEANUP_DONE=1

    set +e

    if [ -n "$COMMON_CLEANUP_FUNCS" ]; then
        # shellcheck disable=SC2086 # intentional word splitting for function list
        set -- $COMMON_CLEANUP_FUNCS
        for func in "$@"; do
            if command -v "$func" >/dev/null 2>&1; then
                "$func" "$status" || true
            fi
        done
    fi

    common_cleanup_tmpdir || true

    exit "$status"
}

trap 'common_cleanup $?' EXIT
trap 'common_cleanup 130' INT
trap 'common_cleanup 143' TERM

common_tmpdir() {
    if [ -n "$COMMON_TMPDIR" ] && [ -d "$COMMON_TMPDIR" ]; then
        printf '%s\n' "$COMMON_TMPDIR"
        return 0
    fi

    base=${TMPDIR:-/tmp}
    if [ ! -d "$base" ]; then
        base=/tmp
    fi

    COMMON_TMPDIR=$(mktemp -d "${base%/}/owrt-common.XXXXXX" 2>/dev/null || printf '')
    if [ -z "$COMMON_TMPDIR" ]; then
        die 'Не удалось создать временный каталог' "$EX_SOFTWARE"
    fi

    common_add_cleanup common_cleanup_tmpdir

    printf '%s\n' "$COMMON_TMPDIR"
}

common_read_version_from_changelog() {
    file=$1
    if [ ! -r "$file" ]; then
        printf ''
        return 1
    fi

    awk '
        /^## \[[0-9]+\.[0-9]+\.[0-9]+\]/ {
            line = $0
            sub(/^## \[/, "", line)
            sub(/\].*$/, "", line)
            print line
            exit
        }
    ' "$file"
}

common_init() {
    if [ -n "$COMMON_PROGRAM" ]; then
        return 0
    fi

    script_path=$1

    if [ -z "${PROGRAM-}" ]; then
        PROGRAM=$(basename "$script_path")
    fi
    COMMON_PROGRAM=$PROGRAM

    if [ -n "${SCRIPT_DIR-}" ]; then
        COMMON_SCRIPT_DIR=$SCRIPT_DIR
    else
        case "$script_path" in
            */*)
                script_source=$(dirname "$script_path")
                ;;
            *)
                lookup=$(command -v -- "$script_path" 2>/dev/null || printf '')
                if [ -n "$lookup" ]; then
                    script_source=$(dirname "$lookup")
                else
                    script_source='.'
                fi
                ;;
        esac

        if ! SCRIPT_DIR=$(cd "$script_source" 2>/dev/null && pwd); then
            printf '%s: unable to determine script directory\n' "$PROGRAM" >&2
            exit 1
        fi
        COMMON_SCRIPT_DIR=$SCRIPT_DIR
    fi

    if [ -z "${PROJECT_ROOT-}" ]; then
        PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
    fi
    COMMON_PROJECT_ROOT=$PROJECT_ROOT

    version_file=$PROJECT_ROOT/VERSION
    share_version_file=${SHARE_VERSION_FILE:-/usr/share/openwrt-extended-backup/VERSION}
    changelog_file=$PROJECT_ROOT/CHANGELOG.md
    version_fallback=${VERSION_FALLBACK:-0.0.0}

    computed_version=''
    if [ -r "$version_file" ]; then
        computed_version=$(head -n 1 "$version_file")
    elif [ -r "$share_version_file" ]; then
        computed_version=$(head -n 1 "$share_version_file")
    else
        computed_version=$(common_read_version_from_changelog "$changelog_file")
    fi

    if [ -z "$computed_version" ]; then
        computed_version=$version_fallback
    fi

    VERSION=$computed_version
    COMMON_VERSION=$computed_version
}

common_print_version() {
    if [ -z "$COMMON_PROGRAM" ] || [ -z "$COMMON_VERSION" ]; then
        common_init "$0"
    fi
    printf '%s version %s\n' "$PROGRAM" "$COMMON_VERSION"
}

common_openwrt_release_path() {
    if [ -n "${OPENWRT_RELEASE_PATH+x}" ] && [ -n "$OPENWRT_RELEASE_PATH" ]; then
        printf '%s\n' "$OPENWRT_RELEASE_PATH"
        return 0
    fi
    printf '/etc/openwrt_release\n'
}

common_is_openwrt() {
    release_path=$(common_openwrt_release_path)
    if [ -r "$release_path" ]; then
        return 0
    fi
    return 1
}

common_openwrt_description() {
    release_path=$(common_openwrt_release_path)
    if [ ! -r "$release_path" ]; then
        return 1
    fi

    awk -F"'" '
        /^DISTRIB_DESCRIPTION=/ {
            if (NF >= 2) {
                print $2
                exit
            }
        }
    ' "$release_path"
}

common_sanitize_token() {
    token=$1
    printf '%s\n' "$token" | tr ' ' '_' | tr -c 'A-Za-z0-9_.-' '_'
}

common_to_bool() {
    value=$1
    case "$value" in
        '' | 0 | [Ff][Aa][Ll][Ss][Ee] | [Nn][Oo] | [Oo][Ff][Ff])
            printf '0\n'
            ;;
        *)
            printf '1\n'
            ;;
    esac
}

common_getopts_consume_value() {
    option_name=$1
    shift

    eval "next_value=\${$OPTIND}"
    if [ -z "${next_value+x}" ] || [ -z "$next_value" ]; then
        die "Опция --$option_name требует аргумент" "$EX_USAGE"
    fi

    case "$next_value" in
        --*)
            die "Опция --$option_name требует аргумент" "$EX_USAGE"
            ;;
    esac

    OPTIND=$((OPTIND + 1))
    printf '%s\n' "$next_value"
}

return 0
