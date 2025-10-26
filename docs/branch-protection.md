# Branch Protection Rules

This document outlines the branch protection rules and CI requirements for the main branch.

## Required Status Checks

The following GitHub Actions workflows must pass before PRs can be merged to main:

- **CI / Lint and test**: Main CI workflow that runs linting, formatting, and tests
- **Shell quality checks / Shell quality**: Dedicated shell script quality checks
- **Post-release verification / Verify release artifacts**: Release artifact validation

## Branch Protection Settings

- **Required status checks**:  Configured
  - CI / Lint and test (from ci.yml)
  - Shell quality checks / Shell quality (from shell-quality.yml)
  - Post-release verification / Verify release artifacts (from post-release-verify.yml)
  - Branch must be up to date with main before merging

- **Branch restrictions**:  Configured
  - Force pushes: Disabled
  - Deletions: Disabled
  - Linear history: Not enforced

- **Admin enforcement**:  Disabled
  - Repository administrators are not exempt from protection rules

## CI Workflows

### 1. CI (ci.yml)
- **Triggers**: push, pull_request to main
- **Jobs**:
  - Lint and test: ShellCheck, shfmt, BATS tests
  - Shell compatibility matrix: Tests across different shells
- **Runner**: ubuntu-latest

### 2. Shell quality checks (shell-quality.yml)
- **Triggers**: push, pull_request to main
- **Jobs**:
  - Shell quality: ShellCheck, shfmt validation
- **Runner**: ubuntu-latest

### 3. Post-release verification (post-release-verify.yml)
- **Triggers**: release published
- **Jobs**:
  - Verify release artifacts: Checksum verification, smoke tests
- **Runner**: ubuntu-latest

## Required Status Check Names

For branch protection to work correctly, ensure these exact names are used:

1. **CI / Lint and test** - from ci.yml job "lint-and-test"
2. **Shell quality checks / Shell quality** - from shell-quality.yml job "shell-quality"
3. **Post-release verification / Verify release artifacts** - from post-release-verify.yml job "verify-artifacts"

## Troubleshooting

If PRs are failing to merge:

1. Check if all required status checks are passing
2. Verify the status check names match exactly
3. Ensure workflows are not failing due to merge conflicts
4. Check that the PR branch is up to date with main

## Branch Naming Convention

- Feature branches: eat/feature-name
- Bug fixes: ix/issue-description
- Hotfixes: hotfix/issue-description
- Releases: elease/vX.Y.Z
- CI/Documentation: ci/*, docs/*, chore/*

## Auto-deletion

- Branches are automatically deleted after PR merge
- No manual cleanup required for merged branches
