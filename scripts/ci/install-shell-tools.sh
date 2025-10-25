#!/bin/sh
# shellcheck shell=sh

set -eu

SHELLCHECK_VERSION="0.10.0"
SHELLCHECK_SHA256="6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87"
SHFMT_VERSION="3.8.0"
SHFMT_SHA256="27b3c6f9d9592fc5b4856c341d1ff2c88856709b9e76469313642a1d7b558fe0"
BATS_VERSION="1.11.0"
BATS_SHA256="aeff09fdc8b0c88b3087c99de00cf549356d7a2f6a69e3fcec5e0e861d2f9063"

TOOLS_ROOT=${TOOLS_ROOT:-"$HOME/.cache/openwrt-toolkit"}
BIN_DIR="$TOOLS_ROOT/bin"
VERSION_FILE="$TOOLS_ROOT/.tool-versions"
EXPECTED_SIGNATURE="shellcheck:${SHELLCHECK_VERSION};shfmt:${SHFMT_VERSION};bats:${BATS_VERSION}"

CURRENT_SIGNATURE=""
if [ -f "$VERSION_FILE" ]; then
    if ! IFS= read -r CURRENT_SIGNATURE <"$VERSION_FILE"; then
        CURRENT_SIGNATURE=""
    fi
fi

if [ "$CURRENT_SIGNATURE" != "$EXPECTED_SIGNATURE" ]; then
    if [ -e "$BIN_DIR" ] || [ -d "$TOOLS_ROOT/libexec" ] || [ -d "$TOOLS_ROOT/share" ]; then
        printf 'Cached tool versions are incompatible. Clearing tool cache.\n'
        rm -rf "$BIN_DIR" "$TOOLS_ROOT/libexec" "$TOOLS_ROOT/share"
    fi
fi

mkdir -p "$BIN_DIR"

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        PATH="$BIN_DIR:$PATH"
        export PATH
        ;;
esac

if [ -n "${GITHUB_PATH:-}" ]; then
    printf '%s\n' "$BIN_DIR" >>"$GITHUB_PATH"
fi

TMP_DIRS=""
cleanup() {
    set +e
    for dir in $TMP_DIRS; do
        if [ -n "$dir" ] && [ -d "$dir" ]; then
            rm -rf "$dir"
        fi
    done
}
trap cleanup EXIT HUP INT TERM

ensure_shellcheck() {
    shellcheck_bin="$BIN_DIR/shellcheck"

    if [ -x "$shellcheck_bin" ]; then
        installed_version=$("$shellcheck_bin" --version 2>/dev/null | awk -F': ' '/version:/ {print $2; exit}')
        if [ "$installed_version" = "$SHELLCHECK_VERSION" ]; then
            printf 'Using cached ShellCheck %s.\n' "$installed_version"
            return
        fi

        printf 'ShellCheck %s found but %s required. Reinstalling.\n' "${installed_version:-unknown}" "$SHELLCHECK_VERSION"
        rm -f "$shellcheck_bin"
    fi

    tmp_dir=$(mktemp -d)
    TMP_DIRS="$TMP_DIRS $tmp_dir"

    archive_path="$tmp_dir/shellcheck.tar.xz"
    archive_url="https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz"

    printf 'Downloading ShellCheck %s...\n' "$SHELLCHECK_VERSION"
    curl -fsSL "$archive_url" -o "$archive_path"
    echo "${SHELLCHECK_SHA256}  ${archive_path}" | sha256sum -c -

    tar -xf "$archive_path" -C "$tmp_dir"
    install -m 0755 "$tmp_dir/shellcheck-v${SHELLCHECK_VERSION}/shellcheck" "$shellcheck_bin"

    rm -rf "$tmp_dir"
    printf 'ShellCheck %s installed.\n' "$SHELLCHECK_VERSION"
}

ensure_shfmt() {
    shfmt_bin="$BIN_DIR/shfmt"

    if [ -x "$shfmt_bin" ]; then
        installed_version=$("$shfmt_bin" --version 2>/dev/null || printf '')
        if [ "$installed_version" = "v${SHFMT_VERSION}" ]; then
            printf 'Using cached shfmt %s.\n' "$installed_version"
            return
        fi

        printf 'shfmt %s found but v%s required. Reinstalling.\n' "${installed_version:-unknown}" "$SHFMT_VERSION"
        rm -f "$shfmt_bin"
    fi

    tmp_dir=$(mktemp -d)
    TMP_DIRS="$TMP_DIRS $tmp_dir"

    archive_path="$tmp_dir/shfmt"
    archive_url="https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_amd64"

    printf 'Downloading shfmt %s...\n' "$SHFMT_VERSION"
    curl -fsSL "$archive_url" -o "$archive_path"
    echo "${SHFMT_SHA256}  ${archive_path}" | sha256sum -c -

    install -m 0755 "$archive_path" "$shfmt_bin"

    rm -rf "$tmp_dir"
    printf 'shfmt %s installed.\n' "$SHFMT_VERSION"
}

ensure_bats() {
    bats_bin="$BIN_DIR/bats"

    if [ -x "$bats_bin" ]; then
        installed_version=$("$bats_bin" --version 2>/dev/null | awk '{print $2; exit}')
        if [ "$installed_version" = "$BATS_VERSION" ]; then
            printf 'Using cached Bats %s.\n' "$installed_version"
            return
        fi

        printf 'Bats %s found but %s required. Reinstalling.\n' "${installed_version:-unknown}" "$BATS_VERSION"
        rm -f "$bats_bin"
        rm -rf "$TOOLS_ROOT/libexec/bats-core" "$TOOLS_ROOT/share/doc/bats"
    fi

    tmp_dir=$(mktemp -d)
    TMP_DIRS="$TMP_DIRS $tmp_dir"

    archive_path="$tmp_dir/bats.tar.gz"
    archive_url="https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz"

    printf 'Downloading Bats %s...\n' "$BATS_VERSION"
    curl -fsSL "$archive_url" -o "$archive_path"
    echo "${BATS_SHA256}  ${archive_path}" | sha256sum -c -

    tar -xf "$archive_path" -C "$tmp_dir"
    bats_src="$tmp_dir/bats-core-${BATS_VERSION}"
    "$bats_src/install.sh" "$TOOLS_ROOT"

    rm -rf "$bats_src"
    rm -f "$archive_path"
    rm -rf "$tmp_dir"
    printf 'Bats %s installed.\n' "$BATS_VERSION"
}

ensure_shellcheck
ensure_shfmt
ensure_bats

printf '%s\n' "$EXPECTED_SIGNATURE" >"$VERSION_FILE"
