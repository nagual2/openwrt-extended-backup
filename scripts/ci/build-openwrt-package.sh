#!/bin/sh
set -eu

FEED_NAME=${FEED_NAME:-ctoolkit}
FEED_PATH=${FEED_PATH:-/work}
OUTPUT_ROOT=${OUTPUT_ROOT:-/work/dist}
TARGET_NAME=${TARGET_NAME:?TARGET_NAME is required}
SDK_DIR=${SDK_DIR:-/sdk}
INDEX_NAME=${INDEX_NAME:-Packages}
ORIGINAL_SDK_DIR=${SDK_DIR}

if [ ! -d "${SDK_DIR}" ]; then
    if [ -d /build ]; then
        SDK_DIR=/build
    elif [ -d /sdk ]; then
        SDK_DIR=/sdk
    else
        echo "Unable to locate SDK directory (${ORIGINAL_SDK_DIR})" >&2
        exit 1
    fi
fi

cd "${SDK_DIR}"

if ! grep -q "src-link ${FEED_NAME} ${FEED_PATH}" feeds.conf.default 2>/dev/null; then
    printf 'src-link %s %s\n' "${FEED_NAME}" "${FEED_PATH}" >> feeds.conf.default
fi

./scripts/feeds update -a
./scripts/feeds install "${FEED_NAME}"

make defconfig
make package/${FEED_NAME}/compile -j1 V=s

PKG_DIR=$(find bin/packages -type d -path "*/${FEED_NAME}" | head -n 1)
if [ -z "${PKG_DIR}" ] || [ ! -d "${PKG_DIR}" ]; then
    echo "Package output directory not found for ${FEED_NAME}" >&2
    exit 1
fi

mkdir -p "${OUTPUT_ROOT}/${TARGET_NAME}"
cp "${PKG_DIR}"/*.ipk "${OUTPUT_ROOT}/${TARGET_NAME}/"

INDEX_TOOL="./staging_dir/host/bin/opkg-make-index"
if [ -x "${INDEX_TOOL}" ]; then
    "${INDEX_TOOL}" "${PKG_DIR}" > "${OUTPUT_ROOT}/${TARGET_NAME}/${INDEX_NAME}"
    gzip -f "${OUTPUT_ROOT}/${TARGET_NAME}/${INDEX_NAME}"
fi

if command -v sha256sum >/dev/null 2>&1; then
    if ls "${OUTPUT_ROOT}/${TARGET_NAME}"/*.ipk >/dev/null 2>&1; then
        (cd "${OUTPUT_ROOT}/${TARGET_NAME}" && sha256sum *.ipk > sha256sums)
    fi
fi
