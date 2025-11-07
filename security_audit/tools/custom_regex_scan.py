#!/usr/bin/env python3
"""Custom regex-based secret scanner for OpenWrt backup repository."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional

REPO_ROOT = Path(__file__).resolve().parents[2]

EXCLUDE_DIRS = {'.git', 'security_audit', '.venv', '__pycache__'}
TARGET_EXTENSIONS: Optional[Iterable[str]] = None  # scan all file types except binaries


@dataclass
class Pattern:
    name: str
    description: str
    severity: str
    regex: re.Pattern


RAW_PATTERNS = [
    ("AWS Access Key ID", "Potential AWS Access Key ID", "HIGH", r"AKIA[0-9A-Z]{16}", re.IGNORECASE),
    (
        "AWS Secret Key",
        "Potential AWS Secret Access Key",
        "CRITICAL",
        r"aws(.{0,20})?(secret|access)?(.{0,20})?(key|token)\s*[:=]\s*['\"]?[0-9a-zA-Z/+]{40}['\"]?",
        re.IGNORECASE,
    ),
    (
        "GitHub Token",
        "Potential GitHub personal access token",
        "HIGH",
        r"gh[pousr]_[0-9a-zA-Z]{36}",
        0,
    ),
    (
        "Generic API Key",
        "Generic API key pattern",
        "HIGH",
        r"(api|token|secret|key)[-_]?(id|key|token|secret)?\s*[:=]\s*['\"]?[0-9a-zA-Z]{16,45}['\"]?",
        re.IGNORECASE,
    ),
    (
        "Database Connection String",
        "Potential database connection string",
        "HIGH",
        r"(postgres|mysql|mongodb|redis|mssql|oracle):/{2}[^\s@]+:[^\s@]+@",
        re.IGNORECASE,
    ),
    (
        "SSH Private Key Block",
        "Private key header",
        "CRITICAL",
        r"-----BEGIN (?:RSA|DSA|EC|OPENSSH) PRIVATE KEY-----",
        0,
    ),
    (
        "TLS Certificate Block",
        "TLS certificate PEM header",
        "HIGH",
        r"-----BEGIN CERTIFICATE-----",
        0,
    ),
    (
        "Email Address",
        "Possible email address (PII)",
        "LOW",
        r"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}",
        re.IGNORECASE,
    ),
    (
        "Phone Number",
        "Possible phone number (PII)",
        "LOW",
        r"(?:(?:\+?\d{1,3})?[\s-]?)?(?:\(\d{3}\)|\d{3})[\s-]?\d{3}[\s-]?\d{4}",
        0,
    ),
    (
        "IPv4 Address",
        "Possible IPv4 address",
        "LOW",
        r"\b(?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\b",
        0,
    ),
    (
        "Internal URL",
        "Possible internal network URL",
        "MEDIUM",
        r"https?://(?:(?:10|127|192\.168|172\.(?:1[6-9]|2\d|3[01]))(?:\.\d{1,3}){2}|localhost)[^\s]*",
        re.IGNORECASE,
    ),
    (
        "Commented Credential",
        "Credential-like value within comment",
        "MEDIUM",
        r"#\s*(?:password|passwd|pwd|secret)\s*[:=]\s*[^\s]+",
        re.IGNORECASE,
    ),
]

PATTERNS: List[Pattern] = [
    Pattern(name, description, severity, re.compile(regex, flags))
    for name, description, severity, regex, flags in RAW_PATTERNS
]


def is_binary(path: Path) -> bool:
    try:
        with path.open('rb') as fh:
            chunk = fh.read(1024)
            if b'\0' in chunk:
                return True
    except (OSError, PermissionError):
        return True
    return False


def iter_files(root: Path) -> Iterable[Path]:
    for path in root.rglob('*'):
        if path.is_dir():
            continue
        if any(part in EXCLUDE_DIRS for part in path.parts):
            continue
        if TARGET_EXTENSIONS and path.suffix not in TARGET_EXTENSIONS:
            continue
        if is_binary(path):
            continue
        yield path


def scan_file(path: Path) -> List[dict]:
    findings: List[dict] = []
    try:
        text = path.read_text(encoding='utf-8', errors='ignore')
    except (OSError, UnicodeDecodeError):
        return findings

    for lineno, line in enumerate(text.splitlines(), start=1):
        for pattern in PATTERNS:
            if pattern.regex.search(line):
                findings.append(
                    {
                        "file": str(path.relative_to(REPO_ROOT)),
                        "line": lineno,
                        "pattern": pattern.name,
                        "severity": pattern.severity,
                        "description": pattern.description,
                        "line_preview": line.strip(),
                    }
                )
    return findings


def main() -> None:
    repo_root = REPO_ROOT
    results: List[dict] = []
    for file_path in iter_files(repo_root):
        results.extend(scan_file(file_path))

    output = {
        "tool": "custom_regex_scan",
        "patterns": [
            {
                "name": p.name,
                "description": p.description,
                "severity": p.severity,
                "pattern": p.regex.pattern,
            }
            for p in PATTERNS
        ],
        "findings": results,
    }

    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
