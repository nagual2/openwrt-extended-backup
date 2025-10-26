# Contributing

Thank you for taking the time to improve this toolkit. The project is maintained by a small team, so following the guidelines below helps us move changes through review quickly and keeps the repository healthy.

## Trunk branch

- The **trunk branch is `main`**. All long–lived work should branch from `main` and merge back into `main` exclusively through pull requests.
- Keep your topic branch up to date by rebasing or merging the latest `main` before requesting review.

## Branch naming policy

Create branches that describe the type of work you are doing. We use the following prefixes:

- `feature/<short-topic>` – new functionality.
- `fix/<short-topic>` – bug fixes or regressions.
- `chore/<short-topic>` – maintenance tasks, documentation-only changes, or repository housekeeping.
- `ci/<short-topic>` – continuous-integration or automation changes.

Use lowercase words separated by hyphens for the `<short-topic>` part (for example, `feature/add-backup-verification`).

## Minimal contribution flow

1. Create a topic branch from `main` using the naming scheme above.
2. Make your changes and run `./scripts/ci/check-shell-quality.sh` locally.
3. Push the branch to your fork (or the main repository if you have access) and open a pull request targeting `main`.
4. Wait for the required checks to succeed:
   - **Shell quality checks / Shell quality**;
   - **Post-release verify / Verify release metadata**.
5. Address review feedback. Changes to `scripts/` and `.github/workflows/` automatically request a maintainer review via `CODEOWNERS`.
6. Merge only after the pull request is approved and all checks are green. Force pushes to `main` are blocked, so use the merge button once CI is finished.

## Local validation checklist

Before opening a pull request:

1. Ensure your branch is based on the latest `main` (`git fetch origin && git rebase origin/main`).
2. Run the quality gate that mirrors the CI pipeline:
   ```sh
   ./scripts/ci/check-shell-quality.sh
   ```
   Resolve any reported issues or formatting patches created under the `reports/` directory.
3. Double-check that executable shell scripts keep their shebangs (`#!/bin/sh`) and remain POSIX-compliant.
4. Update documentation, examples, and changelog entries when behaviour changes.

## Pull request expectations

- Submit focused pull requests that address a single problem.
- Fill out the pull request template completely, including testing notes.
- Request at least one reviewer and respond to feedback promptly. Pull requests that touch `scripts/` or `.github/workflows/` require an approval from the assigned maintainer via `CODEOWNERS`.
- Avoid force-pushing once a review has started unless you are rebasing on top of the latest `main` or addressing review feedback. Mention significant rebases in a comment so reviewers can re-orient themselves.
- Allow the automation to finish after the final approval; do not merge when required checks are still running or failing.

### Required status checks

The repository enforces the following GitHub Actions. Pull requests must be green on all of them before merge:
- **Shell quality checks / Shell quality**
- **Post-release verify / Verify release metadata**

If new checks are added in the future, include them here so contributors know what is expected.

## Maintainer playbook

The steps below require repository administration permissions. Document any deviations in the relevant issue or pull request so contributors stay informed.

### Branch protection for `main` (Status: ✅ Configured)

Branch protection has been configured for the `main` branch with the following settings:

- **Required pull request reviews**: ✅ Enabled
  - Reviews required before merging: Yes
  - Dismiss stale reviews: Yes
  - Require code owner reviews: Yes (enforced by `CODEOWNERS` for `scripts/` and `.github/workflows/`)

- **Required status checks**: ✅ Configured
  - Shell quality checks / Shell quality
  - Post-release verify / Verify release metadata
  - Branch must be up to date with `main` before merging

- **Branch restrictions**: ✅ Configured
  - Force pushes: Disabled
  - Deletions: Disabled
  - Linear history: Not enforced (allows merge commits)

- **Admin enforcement**: ✅ Disabled
  - Repository administrators must follow same rules as contributors

The protection rules are automatically enforced by GitHub and cannot be bypassed.

### Automatic branch cleanup (Status: ✅ Configured)

- **Auto-delete branches after merge**: ✅ Enabled
- Branches are automatically deleted after PR merge
- No manual cleanup required for merged branches

### Periodic branch hygiene (Status: ✅ Completed)

Recent cleanup completed:
- Removed all merged and obsolete branches (15+ branches deleted)
- Kept only active feature branches
- Maintained clean branch history

- **Future maintenance**: At least once per quarter, list remote branches sorted by last activity:
  ```sh
  git for-each-ref --sort=-committerdate --format='%(refname:short) | %(committerdate:short)' refs/remotes/origin
  ```
- Remove fully merged branches. For branches without an open pull request and no activity for 60+ days, check with the branch owner before deleting them.
- Record the cleanup in the relevant tracking issue so contributors know where to find the history.

### Coordinating dependent pull requests

When multiple pull requests touch the same area:

1. Determine the merge order by reviewing overlapping files (`git diff --stat origin/main...branch-name`) and functionality.
2. Communicate the chosen order in the pull request descriptions, including any requirement to rebase after a dependency merges.
3. Use `git range-diff origin/main...branch-a origin/main...branch-b` to highlight conflicting commits before asking authors to rebase.
4. Merge in the agreed order once all required checks are green.

## Getting help

If you are unsure about the process, open a discussion or draft pull request so maintainers can guide you. We are happy to help contributors land their improvements successfully.
