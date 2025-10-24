#!/bin/sh
# shellcheck shell=sh

set -eu

if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is required to bootstrap shell tooling.\n' >&2
    exit 127
fi

SHELLCHECK_VERSION=${SHELLCHECK_VERSION:-v0.10.0}
SHFMT_VERSION=${SHFMT_VERSION:-v3.9.0}
JQ_VERSION=${JQ_VERSION:-jq-1.7.1}

SHELLCHECK_VERSION_NUMBER=${SHELLCHECK_VERSION#v}
TOOLS_ROOT=${TOOLS_ROOT:-"$HOME/.cache/openwrt-shell-tools"}
BIN_DIR="$TOOLS_ROOT/bin"
MANIFEST_FILE="$TOOLS_ROOT/manifest.txt"

required_manifest=$(printf 'shellcheck=%s\nshfmt=%s\njq=%s\n' \
    "$SHELLCHECK_VERSION" "$SHFMT_VERSION" "$JQ_VERSION")

if [ -f "$MANIFEST_FILE" ]; then
    if ! printf '%s' "$required_manifest" | cmp -s - "$MANIFEST_FILE"; then
        rm -rf "$TOOLS_ROOT"
    fi
fi

mkdir -p "$BIN_DIR"
printf '%s' "$required_manifest" >"$MANIFEST_FILE"

add_to_path() {
    case ":${PATH}:" in
        *:"$BIN_DIR":*) ;;
        *) PATH="$BIN_DIR:$PATH" ;;
    esac

    if [ -n "${GITHUB_PATH:-}" ] && ! grep -Fx "$BIN_DIR" "$GITHUB_PATH" >/dev/null 2>&1; then
        printf '%s\n' "$BIN_DIR" >>"$GITHUB_PATH"
    fi
}

download() {
    download_url=$1
    download_path=$2
    curl --fail --silent --show-error --location --retry 5 --retry-delay 2 "$download_url" --output "$download_path"
}

install_shellcheck() {
    dest="$BIN_DIR/shellcheck"
    if [ -x "$dest" ] && "$dest" --version 2>/dev/null | grep -F "$SHELLCHECK_VERSION_NUMBER" >/dev/null 2>&1; then
        return
    fi

    tmpdir=$(mktemp -d)
    archive="$tmpdir/shellcheck.tar.xz"
    download "https://github.com/koalaman/shellcheck/releases/download/$SHELLCHECK_VERSION/shellcheck-$SHELLCHECK_VERSION.linux.x86_64.tar.xz" "$archive"
    tar -C "$tmpdir" -xf "$archive"
    mv "$tmpdir/shellcheck-$SHELLCHECK_VERSION/shellcheck" "$dest"
    chmod +x "$dest"
    rm -rf "$tmpdir"
}

install_shfmt() {
    dest="$BIN_DIR/shfmt"
    if [ -x "$dest" ] && "$dest" --version 2>/dev/null | grep -F "$SHFMT_VERSION" >/dev/null 2>&1; then
        return
    fi

    tmpfile=$(mktemp)
    download "https://github.com/mvdan/sh/releases/download/$SHFMT_VERSION/shfmt_${SHFMT_VERSION}_linux_amd64" "$tmpfile"
    mv "$tmpfile" "$dest"
    chmod +x "$dest"
}

install_jq() {
    dest="$BIN_DIR/jq"
    if [ -x "$dest" ] && "$dest" --version 2>/dev/null | grep -F "$JQ_VERSION" >/dev/null 2>&1; then
        return
    fi

    tmpfile=$(mktemp)
    download "https://github.com/jqlang/jq/releases/download/$JQ_VERSION/jq-linux-amd64" "$tmpfile"
    mv "$tmpfile" "$dest"
    chmod +x "$dest"
}

install_shellcheck
install_shfmt
install_jq
add_to_path

printf 'Shell tooling is ready: shellcheck %s, shfmt %s, jq %s\n' \
    "$SHELLCHECK_VERSION_NUMBER" "$SHFMT_VERSION" "$JQ_VERSION"
