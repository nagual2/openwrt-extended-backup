#!/usr/bin/env bash
# shellcheck shell=bash

# Common helper utilities for bats-core tests.

project_root() {
    if [ -z "${__BATS_PROJECT_ROOT:-}" ]; then
        if [ -z "${BATS_TEST_DIRNAME:-}" ]; then
            fail "BATS_TEST_DIRNAME is not set"
        fi
        __BATS_PROJECT_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    fi
    printf '%s\n' "$__BATS_PROJECT_ROOT"
}

assert_exit_code() {
    local expected=$1
    if [ "${status:-999}" -ne "$expected" ]; then
        fail "expected exit code $expected but got ${status:-unset}"
    fi
}

assert_success() {
    assert_exit_code 0
}

assert_failure() {
    local expected=${1:-1}
    if [ "${status:-0}" -eq 0 ]; then
        fail "expected failure with exit code ${expected}, got success"
    fi
    if [ "$status" -ne "$expected" ]; then
        fail "expected exit code $expected but got $status"
    fi
}

assert_contains() {
    local haystack=$1
    local needle=$2
    case "$haystack" in
        *"$needle"*)
            ;;
        *)
            fail "expected to find substring: $needle"
            ;;
    esac
}

normalize_text() {
    local text=$1
    shift || true
    while [ "$#" -gt 1 ]; do
        local actual=$1
        local placeholder=$2
        text=${text//$actual/$placeholder}
        shift 2
    done
    if [ "$#" -gt 0 ]; then
        fail "normalize_text expects actual/placeholder pairs"
    fi
    printf '%s' "$text"
}

write_text_file() {
    local text=$1
    local dest=$2
    printf '%s' "$text" >"$dest"
    case "$text" in
        *$'\n')
            ;;
        *)
            printf '\n' >>"$dest"
            ;;
    esac
}

assert_normalized_equals() {
    local text=$1
    local expected_file=$2
    shift 2
    local normalized
    normalized=$(normalize_text "$text" "$@")
    local tmp_file="$BATS_TEST_TMPDIR/actual.txt"
    write_text_file "$normalized" "$tmp_file"
    if ! diff -u "$expected_file" "$tmp_file"; then
        fail "output does not match expected content"
    fi
}
