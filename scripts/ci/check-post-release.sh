#!/bin/sh
set -eu

python3 <<'PY'
import json
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(1)


config_path = Path('release-please-config.json')
try:
    config = json.loads(config_path.read_text(encoding='utf-8'))
except Exception as exc:  # pragma: no cover - defensive
    fail(f'Failed to parse {config_path}: {exc}')

packages = config.get('packages')
if not isinstance(packages, dict):
    fail('release-please config must define a "packages" object')

root_config = packages.get('.')
if not isinstance(root_config, dict):
    fail('release-please config must define settings for the root package (".")')

required_keys = {'release-type', 'changelog-path', 'extra-files'}
missing_keys = sorted(required_keys - root_config.keys())
if missing_keys:
    fail('release-please root package is missing keys: ' + ', '.join(missing_keys))

extra_files = root_config.get('extra-files')
if not isinstance(extra_files, list):
    fail('release-please root package must define "extra-files" as a list')

expected_paths = {'VERSION', 'scripts/openwrt_full_backup', 'scripts/user_installed_packages'}
paths = {item.get('path') for item in extra_files if isinstance(item, dict)}
missing_paths = sorted(expected_paths - paths)
if missing_paths:
    fail('release-please extra-files is missing entries for: ' + ', '.join(missing_paths))
PY

python3 <<'PY'
import json
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(1)


manifest_path = Path('.release-please-manifest.json')
try:
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
except Exception as exc:  # pragma: no cover - defensive
    fail(f'Failed to parse {manifest_path}: {exc}')

if '.' not in manifest:
    fail('Manifest must include version for root package "."')
PY

echo 'Release metadata structure looks good.'
