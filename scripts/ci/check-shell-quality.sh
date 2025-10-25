#!/bin/sh
# shellcheck shell=sh

set -eu

if ! command -v git >/dev/null 2>&1; then
    printf 'git is required to run shell quality checks.\n' >&2
    exit 127
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT" || exit 1

REPORT_DIR="$REPO_ROOT/reports"
mkdir -p "$REPORT_DIR"

SHELL_FILES_LIST="$REPORT_DIR/shell-files.txt"
SHEBANG_REPORT="$REPORT_DIR/shebang-violations.txt"
EVAL_REPORT="$REPORT_DIR/unsafe-eval.txt"
UNQUOTED_REPORT="$REPORT_DIR/unquoted-variables.txt"
SHFMT_REPORT="$REPORT_DIR/shfmt.patch"
SHELLCHECK_JSON="$REPORT_DIR/shellcheck.json"
SHELLCHECK_REPORT="$REPORT_DIR/shellcheck.txt"

rm -f "$SHELL_FILES_LIST" "$SHEBANG_REPORT" "$EVAL_REPORT" "$UNQUOTED_REPORT" \
    "$SHFMT_REPORT" "$SHELLCHECK_JSON" "$SHELLCHECK_REPORT"

list_shell_files() {
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
    done
}

list_shell_files | sort -u >"$SHELL_FILES_LIST"

if [ ! -s "$SHELL_FILES_LIST" ]; then
    printf 'No shell scripts detected. Nothing to check.\n'
    exit 0
fi

while IFS= read -r path; do
    first_line=$(sed -n '1p' "$path" 2>/dev/null || printf '')
    case "$first_line" in
        '#!/bin/sh' | '#!/usr/bin/env sh') ;;
        '#!'*)
            {
                printf '%s: unexpected shebang: %s\n' "$path" "$first_line"
            } >>"$SHEBANG_REPORT"
            ;;
        '')
            {
                printf '%s: missing shebang\n' "$path"
            } >>"$SHEBANG_REPORT"
            ;;
        *)
            {
                printf '%s: missing shebang\n' "$path"
            } >>"$SHEBANG_REPORT"
            ;;
    esac

    awk '
        /\beval\b/ {
            line = $0
            sub(/^[[:space:]]+/, "", line)
            if (line ~ /^#/) {
                next
            }
            printf "%s:%d: %s\n", FILENAME, NR, $0
        }
    ' "$path" >>"$EVAL_REPORT"
done <"$SHELL_FILES_LIST"

SHEBANG_ERRORS=0
if [ -s "$SHEBANG_REPORT" ]; then
    SHEBANG_ERRORS=1
else
    rm -f "$SHEBANG_REPORT"
fi

EVAL_ERRORS=0
if [ -s "$EVAL_REPORT" ]; then
    EVAL_ERRORS=1
else
    rm -f "$EVAL_REPORT"
fi

set --
while IFS= read -r path; do
    set -- "$@" "$path"
done <"$SHELL_FILES_LIST"

SHFMT_STATUS=0
if [ "$#" -gt 0 ]; then
    if ! shfmt -i 4 -ci -d "$@" >"$SHFMT_REPORT"; then
        SHFMT_STATUS=$?
    fi
    if [ -s "$SHFMT_REPORT" ]; then
        SHFMT_STATUS=1
    else
        rm -f "$SHFMT_REPORT"
    fi
fi

SHELLCHECK_STATUS=0
if [ "$#" -gt 0 ]; then
    if shellcheck --severity=warning --format=json "$@" >"$SHELLCHECK_JSON"; then
        SHELLCHECK_STATUS=0
    else
        SHELLCHECK_STATUS=$?
    fi
fi

if [ -f "$SHELLCHECK_JSON" ] && jq -e 'length > 0' "$SHELLCHECK_JSON" >/dev/null 2>&1; then
    jq -r '.[] | "SC\(.code) [\(.level)] \(.file):\(.line):\(.column): \(.message)"' \
        "$SHELLCHECK_JSON" >"$SHELLCHECK_REPORT"
    if [ -s "$SHELLCHECK_REPORT" ]; then
        :
    else
        rm -f "$SHELLCHECK_REPORT"
    fi
fi

UNQUOTED_ERRORS=0
if [ -f "$SHELLCHECK_JSON" ] &&
    jq -e 'map(select(.code == 2046 or .code == 2086 or .code == 2145)) | length > 0' \
        "$SHELLCHECK_JSON" >/dev/null 2>&1; then
    jq -r 'map(select(.code == 2046 or .code == 2086 or .code == 2145))[] |
        "SC\(.code) [\(.level)] \(.file):\(.line):\(.column): \(.message)"' \
        "$SHELLCHECK_JSON" >"$UNQUOTED_REPORT"
    UNQUOTED_ERRORS=1
else
    rm -f "$UNQUOTED_REPORT"
fi

BATS_STATUS=0
BATS_SAMPLE=''
if command -v bats >/dev/null 2>&1; then
    if [ -d "$REPO_ROOT/tests" ]; then
        BATS_SAMPLE=$(find "$REPO_ROOT/tests" -name '*.bats' -print -quit 2>/dev/null || printf '')
        if [ -n "$BATS_SAMPLE" ]; then
            printf '\nRunning bats tests...\n'
            if ! BATS_LIB_PATH="$REPO_ROOT/tests/lib" bats --print-output-on-failure --timing "$REPO_ROOT/tests"; then
                BATS_STATUS=$?
            fi
        fi
    fi
else
    if [ -d "$REPO_ROOT/tests" ]; then
        BATS_SAMPLE=$(find "$REPO_ROOT/tests" -name '*.bats' -print -quit 2>/dev/null || printf '')
        if [ -n "$BATS_SAMPLE" ]; then
            printf 'bats command not found; skipping bats tests.\n' >&2
        fi
    fi
fi

if [ "$SHEBANG_ERRORS" -ne 0 ] && [ -f "$SHEBANG_REPORT" ]; then
    printf '\nShebang violations detected:\n' >&2
    cat "$SHEBANG_REPORT" >&2
fi

if [ "$EVAL_ERRORS" -ne 0 ] && [ -f "$EVAL_REPORT" ]; then
    printf '\nUnsafe eval usage detected:\n' >&2
    cat "$EVAL_REPORT" >&2
fi

if [ "$SHFMT_STATUS" -ne 0 ] && [ -f "$SHFMT_REPORT" ]; then
    printf '\nshfmt suggested changes:\n' >&2
    cat "$SHFMT_REPORT" >&2
fi

if [ "$SHELLCHECK_STATUS" -ne 0 ] && [ -f "$SHELLCHECK_REPORT" ]; then
    printf '\nShellCheck findings:\n' >&2
    cat "$SHELLCHECK_REPORT" >&2
fi

if [ "$UNQUOTED_ERRORS" -ne 0 ] && [ -f "$UNQUOTED_REPORT" ]; then
    printf '\nUnquoted variable usage detected:\n' >&2
    cat "$UNQUOTED_REPORT" >&2
fi

EXIT_STATUS=0
if [ "$SHEBANG_ERRORS" -ne 0 ] || [ "$EVAL_ERRORS" -ne 0 ] || [ "$SHFMT_STATUS" -ne 0 ] ||
    [ "$SHELLCHECK_STATUS" -ne 0 ] || [ "$UNQUOTED_ERRORS" -ne 0 ] || [ "$BATS_STATUS" -ne 0 ]; then
    EXIT_STATUS=1
fi

if [ "$EXIT_STATUS" -eq 0 ]; then
    printf 'Shell quality checks passed.\n'
else
    printf 'Shell quality checks failed.\n' >&2
fi

exit "$EXIT_STATUS"
