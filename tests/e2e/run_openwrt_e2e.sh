#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/owrt-e2e-XXXXXX")
IMAGE_URL=${OPENWRT_IMAGE_URL:-"https://downloads.openwrt.org/releases/23.05.3/targets/x86/64/openwrt-23.05.3-x86-64-generic-squashfs-combined.img.gz"}
IMAGE_PATH="$WORK_DIR/openwrt.img"
HTTP_SERVER_LOG="$WORK_DIR/http-server.log"
SERIAL_LOG="$WORK_DIR/serial.log"
EXPECT_SCRIPT="$SCRIPT_DIR/qemu_openwrt.expect"

find_free_port() {
    python3 - <<'PY'
import socket
with socket.socket() as sock:
    sock.bind(('127.0.0.1', 0))
    print(sock.getsockname()[1])
PY
}

require_tools() {
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            printf 'Required tool not found: %s\n' "$tool" >&2
            exit 1
        fi
    done
}

cleanup() {
    set +e
    if [ -n "${HTTP_PID:-}" ] && kill -0 "$HTTP_PID" >/dev/null 2>&1; then
        kill "$HTTP_PID" >/dev/null 2>&1 || true
        wait "$HTTP_PID" 2>/dev/null || true
    fi
    if [ -n "${ARTIFACT_DIR:-}" ]; then
        mkdir -p "$ARTIFACT_DIR"
        if [ -f "$SERIAL_LOG" ]; then
            cp "$SERIAL_LOG" "$ARTIFACT_DIR/serial.log" 2>/dev/null || true
        fi
        if [ -f "$HTTP_SERVER_LOG" ]; then
            cp "$HTTP_SERVER_LOG" "$ARTIFACT_DIR/http-server.log" 2>/dev/null || true
        fi
    fi
    rm -rf "$WORK_DIR"
}

trap cleanup EXIT INT TERM

require_tools curl gzip python3 expect qemu-system-x86_64 tar

HTTP_PORT_ENV=${E2E_HTTP_PORT:-}
FETCH_PORT_ENV=${E2E_FETCH_PORT:-}
if [ -n "$HTTP_PORT_ENV" ]; then
    HTTP_PORT=$HTTP_PORT_ENV
else
    HTTP_PORT=$(find_free_port)
fi
if [ -n "$FETCH_PORT_ENV" ]; then
    FETCH_PORT=$FETCH_PORT_ENV
else
    FETCH_PORT=$(find_free_port)
fi
while [ "$HTTP_PORT" = "$FETCH_PORT" ]; do
    FETCH_PORT=$(find_free_port)
    sleep 0.1
done

ARTIFACT_DIR_INPUT=${ARTIFACT_DIR:-"$REPO_ROOT/tests/e2e/artifacts"}
ARTIFACT_DIR_ABS=$(python3 - <<'PY'
import os, sys
print(os.path.abspath(sys.argv[1]))
PY
"$ARTIFACT_DIR_INPUT")
ARTIFACT_DIR="$ARTIFACT_DIR_ABS"
rm -rf "$ARTIFACT_DIR"
mkdir -p "$ARTIFACT_DIR"

printf '==> Downloading OpenWrt image from %s\n' "$IMAGE_URL"
curl -L --fail --retry 5 --retry-delay 1 -o "$WORK_DIR/openwrt.img.gz" "$IMAGE_URL"
gzip -d "$WORK_DIR/openwrt.img.gz"
if [ ! -s "$IMAGE_PATH" ]; then
    printf 'Decompressed image not found at %s\n' "$IMAGE_PATH" >&2
    exit 1
fi

printf '==> Starting temporary HTTP server on host port %s\n' "$HTTP_PORT"
python3 -m http.server "$HTTP_PORT" --directory "$REPO_ROOT" --bind 0.0.0.0 >"$HTTP_SERVER_LOG" 2>&1 &
HTTP_PID=$!

wait_for_http() {
    local attempts=0
    local max_attempts=${1:-20}
    local delay=${2:-0.5}
    while [ "$attempts" -lt "$max_attempts" ]; do
        if curl -fsS "http://127.0.0.1:$HTTP_PORT/README.md" >/dev/null 2>&1; then
            return 0
        fi
        attempts=$((attempts + 1))
        sleep "$delay"
    done
    return 1
}

if ! wait_for_http 30 0.5; then
    printf 'HTTP server failed to start on port %s\n' "$HTTP_PORT" >&2
    exit 1
fi

printf '==> Launching OpenWrt VM via QEMU (guest HTTP forward port %s)\n' "$FETCH_PORT"
expect -f "$EXPECT_SCRIPT" "$IMAGE_PATH" "$ARTIFACT_DIR" "$SERIAL_LOG" "$HTTP_PORT" "$FETCH_PORT"

TARBALL_PATH=$(find "$ARTIFACT_DIR" -maxdepth 1 -name 'fullbackup_*.tar.gz' | head -n 1 || true)
if [ -z "$TARBALL_PATH" ]; then
    printf 'Backup archive not found in %s\n' "$ARTIFACT_DIR" >&2
    exit 1
fi

printf '==> Verifying backup archive: %s\n' "$TARBALL_PATH"
if ! tar -tzf "$TARBALL_PATH" >/dev/null 2>&1; then
    printf 'Backup archive is corrupted or unreadable: %s\n' "$TARBALL_PATH" >&2
    exit 1
fi

if ! tar -tzf "$TARBALL_PATH" | grep -q 'overlay/upper/etc/e2e/message.txt'; then
    printf 'Expected file missing in archive: overlay/upper/etc/e2e/message.txt\n' >&2
    exit 1
fi

MESSAGE_CONTENT=$(tar -xOf "$TARBALL_PATH" overlay/upper/etc/e2e/message.txt)
if [ "$MESSAGE_CONTENT" != 'payload from e2e' ]; then
    printf 'Unexpected content in message.txt: %s\n' "$MESSAGE_CONTENT" >&2
    exit 1
fi

if ! tar -tzf "$TARBALL_PATH" | grep -q 'overlay/upper/etc/e2e/extra.txt'; then
    printf 'Expected file missing in archive: overlay/upper/etc/e2e/extra.txt\n' >&2
    exit 1
fi

printf '==> OpenWrt backup E2E test completed successfully.\n'
