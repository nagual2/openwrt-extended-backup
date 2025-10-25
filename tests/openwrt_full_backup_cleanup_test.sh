#!/bin/sh
set -eu

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)
SCRIPT_PATH="$PROJECT_ROOT/scripts/openwrt_full_backup"

TEST_ROOT=$(mktemp -d)
cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT INT TERM

OUT_DIR="$TEST_ROOT/out"
mkdir -p "$OUT_DIR"

STUB_DIR="$TEST_ROOT/stubs"
mkdir -p "$STUB_DIR"

REAL_TAR=$(command -v tar)

cat >"$STUB_DIR/tar" <<EOF
#!/bin/sh
if [ "\$1" = "-czpf" ]; then
    output=\$2
    shift 2
    printf 'partial archive' >"\$output"
    exit 1
fi
exec "$REAL_TAR" "\$@"
EOF
chmod +x "$STUB_DIR/tar"

export PATH="$STUB_DIR:$PATH"

set +e
"$SCRIPT_PATH" --export=local --out-dir "$OUT_DIR" >/dev/null 2>&1
status=$?
set -e

if [ "$status" -eq 0 ]; then
    echo "expected failure from openwrt_full_backup with stubbed tar" >&2
    exit 1
fi

if [ -n "$(find "$OUT_DIR" -maxdepth 1 -type f -print -quit)" ]; then
    echo "archive file was not removed after failure" >&2
    exit 1
fi

echo "openwrt_full_backup cleanup failure path test passed."
