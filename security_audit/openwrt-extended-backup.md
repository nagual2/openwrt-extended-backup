# OpenWrt Extended Backup Security Audit

_Date: 2025-11-07_

## Executive Summary
- Conducted a comprehensive secret and sensitive data assessment of the `openwrt-extended-backup` repository, covering the working tree and full git history.
- Automated and manual reviews identified one **critical** exposure – an authenticated GitHub remote URL containing a Personal Access Token (PAT) stored in the local `.git/config`.
- All other scanner hits (test fixtures, workflow commit SHAs, public keys) were confirmed to be non-sensitive or intentional and are documented as informational.
- Immediate remediation is required to revoke the exposed PAT and to eliminate credentialed remotes from contributor tooling. Additional preventive controls are recommended to avoid future secret leaks.

## Methodology
### Toolchain & Environment
- Python 3.12 virtual environment (`security_audit/.venv`)
- `detect-secrets` 1.5.0 (working tree scan; high-entropy & provider rules)
- Custom regex scanner (`security_audit/tools/custom_regex_scan.py`) covering API keys, PATs, AWS credentials, DB URIs, SSH/TLS materials, PII, internal URLs, and commented credentials.
- `trufflehog` 2.2.1 (high-entropy scan of working tree and full git history)
- `ripgrep` 14.1.0 for targeted manual sweeps

### Scope & File Inventory
Working tree files scanned (excluding `security_audit` artifacts):

| Pattern | Count |
| --- | ---: |
| `*.md` | 22 |
| `*.txt` | 10 |
| `*.sh` | 8 |
| `*.yml` | 10 |
| `*.yaml` | 1 |
| `Makefile` | 3 |
| `*.json` | 3 |
| `*.env` / `*.conf` / `*.config` / `*.key` / `*.pem` / `*.crt` | 0 |
| `.git/config` | 1 |

Priority directories (`./`, `.github/workflows/`, `scripts/`, `docs/`, `tests/`, `tools/`) received additional line-by-line inspection.

### Automated Scan Artifacts
Raw outputs archived under `security_audit/logs/`:
- `detect_secrets_working_tree.json`
- `custom_regex_scan_working_tree.json`
- `trufflehog_head.json` and `trufflehog_history.json`
- `file_inventory.txt`

## Findings

| Severity | Location | Description | Evidence (sanitized) | Status |
| --- | --- | --- | --- | --- |
| **CRITICAL** | `.git/config` (local) | Git remote includes GitHub PAT (`ghs_…`) embedded in HTTPS URL. Exposes full repository access for user `nagual2`. | `url = https://nagual2:<redacted>@github.com/nagual2/openwrt-extended-backup.git` (line 7) | **Open** – immediate action required |
| LOW | `tests/openwrt_full_backup.bats` (line 229) | Hard-coded test password `Secret123` used in fixture. Not a production secret but repeatedly triggers scanners. | `export KSMBD_PASSWORD='Secret123'` | Accepted risk; consider neutral placeholder |
| INFO | Multiple workflow files under `tools/bats-core/.github/workflows/` | High-entropy strings are pinned commit SHAs for third-party GitHub Actions. | e.g. `actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11` | No action – expected |
| INFO | `tools/bats-core/docker/tini.pubkey.gpg` | Public PGP key bundled with upstream tooling. | `-----BEGIN PGP PUBLIC KEY BLOCK-----` | No action – intended distribution |

No AWS keys, database credentials, TLS private keys, or PII were found in tracked content beyond the items noted above.

## Remediation Plan
1. **Revoke & rotate exposed GitHub PAT (CRITICAL)**
   - Owner: `nagual2`
   - Action: Revoke `ghs_*` token via GitHub security settings, generate a new token if needed, and audit logs for misuse.
   - Replace credentialed remote URLs with SSH remotes or use Git credential helpers so PATs are not written to `.git/config`.

2. **Hygiene improvements for test fixtures (LOW)**
   - Optional: Change `Secret123` to an obviously non-sensitive placeholder (e.g. `TEST_ONLY_PASSWORD`) to reduce scanner noise.

## Preventive Recommendations
- Enforce secret scanning pre-commit hooks (e.g. `detect-secrets hook`) and integrate automated secret scanning (GitHub Advanced Security, Gitleaks, or detect-secrets) into CI pipelines.
- Standardize contributor setup guidance to avoid storing PATs in plain text (prefer SSH keys, credential helpers, or environment variables).
- Maintain dedicated sample configuration files with clearly redacted values; avoid real credentials even in examples or tests.
- Schedule periodic repository audits (including git history) following release cycles or contributor onboarding waves.
- Consider adding a `.gitleaks.toml` or detect-secrets baseline to document acceptable secrets and reduce false positives while maintaining vigilance.

## Checklist
- [ ] Revoke exposed GitHub PAT and audit for misuse.
- [ ] Update remote configuration guidance for contributors (use SSH / credential helper).
- [ ] (Optional) Rename test fixture password to an explicit placeholder.
- [ ] Adopt continuous secret scanning in CI & contributor workflows.

---
_All supporting logs and custom tooling reside under `security_audit/` for future reference._
