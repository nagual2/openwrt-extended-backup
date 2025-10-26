#!/bin/sh
set -eu

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)
SCRIPT_PATH="$PROJECT_ROOT/scripts/openwrt_full_restore"

TEST_ROOT=$(mktemp -d)
cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT INT TERM

STUB_DIR="$TEST_ROOT/stubs"
mkdir -p "$STUB_DIR"

REAL_ID=$(command -v id)

cat >"$STUB_DIR/id" <<EOF
#!/bin/sh
if [ "\$1" = "-u" ]; then
    printf '0\n'
    exit 0
fi
exec "$REAL_ID" "\$@"
EOF
chmod +x "$STUB_DIR/id"

export PATH="$STUB_DIR:$PATH"

TMP_SUB="$TEST_ROOT/tmp"
mkdir -p "$TMP_SUB"
export TMPDIR="$TMP_SUB"

BAD_ARCHIVE="$TEST_ROOT/bad.tar.gz"
: >"$BAD_ARCHIVE"

set +e
"$SCRIPT_PATH" --archive "$BAD_ARCHIVE" >/dev/null 2>&1
status=$?
set -e

if [ "$status" -eq 0 ]; then
    echo "expected failure from openwrt_full_restore on invalid archive" >&2
    exit 1
fi

if [ -n "$(find "$TMP_SUB" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    echo "temporary files were not cleaned after failure" >&2
    exit 1
fi

echo "openwrt_full_restore cleanup failure path test passed."
