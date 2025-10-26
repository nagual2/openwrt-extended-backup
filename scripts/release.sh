#!/bin/sh
# shellcheck shell=sh

set -eu

PROGRAM=$(basename "$0")

EX_OK=0
EX_USAGE=64
EX_UNAVAILABLE=69
EX_SOFTWARE=70

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

if ! SCRIPT_DIR=$(cd "$SCRIPT_SOURCE" 2>/dev/null && pwd); then
    printf '%s: unable to determine script directory\n' "$PROGRAM" >&2
    exit $EX_SOFTWARE
fi

PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
VERSION_FILE="$PROJECT_ROOT/VERSION"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

usage() {
    cat <<EOF
Usage: $PROGRAM <new-version>

Bump the project version, prepend a changelog stub, commit the changes,
and create an annotated Git tag for the provided version.

Environment variables:
  RELEASE_DATE  Override the release date inserted into CHANGELOG.md (format YYYY-MM-DD).
EOF
}

die() {
    message=$1
    code=${2:-$EX_SOFTWARE}
    printf '%s: %s\n' "$PROGRAM" "$message" >&2
    exit "$code"
}

read_version_from_file() {
    file=$1

    if [ ! -r "$file" ]; then
        die "Unable to read version file: $file" "$EX_UNAVAILABLE"
    fi

    first_line=$(head -n 1 "$file" 2>/dev/null || printf '')
    version=$(printf '%s' "$first_line" | tr -d ' \t\r\n')

    if [ -z "$version" ]; then
        die "Version file is empty: $file" "$EX_USAGE"
    fi

    printf '%s\n' "$version"
}

validate_semver() {
    version=$1

    case "$version" in
        '')
            die 'Version cannot be empty' "$EX_USAGE"
            ;;
        *[!0-9.]* )
            die "Version must contain only digits and dots: $version" "$EX_USAGE"
            ;;
    esac

    case "$version" in
        *.*.*.*)
            die "Version must have major.minor.patch format: $version" "$EX_USAGE"
            ;;
        *.*.*)
            ;;
        *)
            die "Version must have major.minor.patch format: $version" "$EX_USAGE"
            ;;
    esac

    major=$(printf '%s' "$version" | cut -d '.' -f1)
    minor=$(printf '%s' "$version" | cut -d '.' -f2)
    patch=$(printf '%s' "$version" | cut -d '.' -f3)

    if [ -z "$major" ] || [ -z "$minor" ] || [ -z "$patch" ]; then
        die "Version must have three numeric segments: $version" "$EX_USAGE"
    fi
}

is_version_greater() {
    current=$1
    candidate=$2

    current_major=$(printf '%s' "$current" | cut -d '.' -f1)
    current_minor=$(printf '%s' "$current" | cut -d '.' -f2)
    current_patch=$(printf '%s' "$current" | cut -d '.' -f3)

    candidate_major=$(printf '%s' "$candidate" | cut -d '.' -f1)
    candidate_minor=$(printf '%s' "$candidate" | cut -d '.' -f2)
    candidate_patch=$(printf '%s' "$candidate" | cut -d '.' -f3)

    if [ "$candidate_major" -gt "$current_major" ]; then
        return 0
    fi
    if [ "$candidate_major" -lt "$current_major" ]; then
        return 1
    fi

    if [ "$candidate_minor" -gt "$current_minor" ]; then
        return 0
    fi
    if [ "$candidate_minor" -lt "$current_minor" ]; then
        return 1
    fi

    if [ "$candidate_patch" -gt "$current_patch" ]; then
        return 0
    fi

    return 1
}

require_clean_worktree() {
    (
        cd "$PROJECT_ROOT" 2>/dev/null || exit $EX_SOFTWARE
        if [ -n "$(git status --porcelain)" ]; then
            die 'Working tree has uncommitted changes. Commit or stash them before running.' "$EX_UNAVAILABLE"
        fi
    )
}

ensure_tag_absent() {
    version=$1
    (
        cd "$PROJECT_ROOT" 2>/dev/null || exit $EX_SOFTWARE
        if git rev-parse --quiet --verify "refs/tags/v$version" >/dev/null; then
            die "Tag v$version already exists" "$EX_UNAVAILABLE"
        fi
    )
}

extract_compare_base_url() {
    changelog_file=$1
    awk '
        match($0, /\((https:\/\/[^)]*)\)/, m) {
            split(m[1], parts, "/compare/")
            if (parts[1] != "") {
                print parts[1]
                exit
            }
        }
    ' "$changelog_file"
}

build_changelog_stub() {
    changelog_file=$1
    new_version=$2
    previous_version=$3
    release_date=$4

    base_url=$(extract_compare_base_url "$changelog_file")

    if [ -n "$base_url" ] && [ -n "$previous_version" ]; then
        header="## [$new_version](${base_url}/compare/v${previous_version}...v${new_version}) ($release_date)"
    else
        header="## [$new_version] - $release_date"
    fi

    cat <<EOF
$header

### What's Changed
- _Add release notes._
EOF
}

insert_changelog_entry() {
    changelog_file=$1
    new_version=$2
    previous_version=$3
    release_date=$4

    if [ ! -f "$changelog_file" ]; then
        die "Changelog file not found: $changelog_file" "$EX_UNAVAILABLE"
    fi

    stub=$(build_changelog_stub "$changelog_file" "$new_version" "$previous_version" "$release_date")
    tmp=$(mktemp)
    inserted=0

    while IFS= read -r line || [ -n "$line" ]; do
        printf '%s\n' "$line" >>"$tmp"
        if [ "$inserted" -eq 0 ] && [ "$line" = '# Changelog' ]; then
            printf '\n%s\n' "$stub" >>"$tmp"
            inserted=1
        fi
    done <"$changelog_file"

    if [ "$inserted" -eq 0 ]; then
        rm -f "$tmp"
        die "Unable to locate changelog heading in $changelog_file" "$EX_SOFTWARE"
    fi

    mv "$tmp" "$changelog_file"
}

update_version_file() {
    new_version=$1
    if ! printf '%s\n' "$new_version" >"$VERSION_FILE"; then
        die "Failed to update VERSION file" "$EX_UNAVAILABLE"
    fi
}

create_release_commit() {
    new_version=$1
    (
        cd "$PROJECT_ROOT" 2>/dev/null || exit $EX_SOFTWARE
        git add VERSION CHANGELOG.md
        git commit -m "chore: release v$new_version"
    )
}

create_annotated_tag() {
    new_version=$1
    (
        cd "$PROJECT_ROOT" 2>/dev/null || exit $EX_SOFTWARE
        git tag -a "v$new_version" -m "Release v$new_version"
    )
}

main() {
    if [ $# -eq 0 ]; then
        usage
        exit $EX_USAGE
    fi

    case "$1" in
        -h | --help)
            usage
            exit $EX_OK
            ;;
    esac

    if [ $# -gt 1 ]; then
        die 'Too many arguments provided.' "$EX_USAGE"
    fi

    new_version=$1

    validate_semver "$new_version"

    current_version=$(read_version_from_file "$VERSION_FILE")
    validate_semver "$current_version"

    if ! is_version_greater "$current_version" "$new_version"; then
        die "New version $new_version must be greater than current $current_version" "$EX_USAGE"
    fi

    release_date=${RELEASE_DATE:-$(date +%Y-%m-%d)}

    require_clean_worktree
    ensure_tag_absent "$new_version"

    update_version_file "$new_version"
    insert_changelog_entry "$CHANGELOG_FILE" "$new_version" "$current_version" "$release_date"

    create_release_commit "$new_version"
    create_annotated_tag "$new_version"

    printf 'Prepared release v%s.\n' "$new_version"
    printf '\nNext steps:\n'
    printf '  1. Review CHANGELOG.md and adjust the placeholder section.\n'
    printf '  2. git push origin HEAD\n'
    printf '  3. git push origin v%s\n' "$new_version"
    printf '  4. Publish the GitHub release with the updated notes.\n'
}

if [ "${RELEASE_HELPER_NO_MAIN:-0}" -ne 1 ]; then
    main "$@"
fi
