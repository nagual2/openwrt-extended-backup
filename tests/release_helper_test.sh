#!/bin/sh
set -eu

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)

RELEASE_HELPER_NO_MAIN=1
# shellcheck disable=SC1091
. "$PROJECT_ROOT/scripts/release.sh"

TMP_FILES=''

register_tmp() {
    TMP_FILES="$TMP_FILES $1"
}

cleanup() {
    for file in $TMP_FILES; do
        if [ -f "$file" ]; then
            rm -f "$file"
        fi
    done
}

trap cleanup EXIT INT TERM

test_parse_version() {
    tmp=$(mktemp)
    register_tmp "$tmp"

    printf '  2.3.4  \nlegacy\n' >"$tmp"

    parsed=$(read_version_from_file "$tmp")

    if [ "$parsed" != "2.3.4" ]; then
        printf 'Expected parsed version to be 2.3.4, got %s\n' "$parsed" >&2
        exit 1
    fi
}

test_changelog_insertion() {
    changelog=$(mktemp)
    register_tmp "$changelog"
    cat <<'EOF' >"$changelog"
# Changelog

## [1.0.0](https://github.com/example/project/compare/v0.9.0...v1.0.0) (2024-10-20)

### Existing
- previous entry
EOF

    insert_changelog_entry "$changelog" "1.1.0" "1.0.0" "2024-10-21"

    expected=$(mktemp)
    register_tmp "$expected"
    cat <<'EOF' >"$expected"
# Changelog

## [1.1.0](https://github.com/example/project/compare/v1.0.0...v1.1.0) (2024-10-21)

### What's Changed
- _Add release notes._

## [1.0.0](https://github.com/example/project/compare/v0.9.0...v1.0.0) (2024-10-20)

### Existing
- previous entry
EOF

    if ! diff -u "$expected" "$changelog"; then
        printf 'Changelog insertion test failed.\n' >&2
        exit 1
    fi
}

test_parse_version
test_changelog_insertion

printf 'All release helper tests passed.\n'
