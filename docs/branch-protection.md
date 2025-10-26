# Branch Protection Rules

This document captures the current protection settings that are applied to the `main` branch.

## Required Status Checks

Pull requests targeting `main` can merge once the following checks report success:

- **Shell quality / shell quality** – static analysis, formatting, and BATS tests
- **Shell quality / Post-release verify** – placeholder job ensuring the workflow stays green

> **Branch must be up to date:** `strict: true` is enabled, so PR branches must be rebased/merged with `main` before GitHub will mark the checks as satisfied.

## Pull Request Reviews

- Approvals are **not required** (`required_approving_review_count = 0`).
- Code owner reviews are **not required**.
- Dismissal rules and stale review policies are **disabled**.

With these settings, a PR with passing checks can merge (or auto-merge) without human intervention.

## Additional Protection Settings

- Force pushes: **Disabled**
- Branch deletions: **Disabled**
- Linear history: **Not enforced**
- Admin enforcement: **Disabled**
- Required conversation resolution: **Disabled**

## Applying the Configuration via API

1. Ensure `branch-protection-full.json` in the repository root reflects the desired settings (see latest contents in version control).
2. Run the following command with repository admin credentials:

   ```bash
   OWNER="<github-owner>"
   REPO="<repository-name>"
   TOKEN="<github-personal-access-token>"

   curl -sS -X PUT \
     -H "Accept: application/vnd.github+json" \
     -H "Authorization: Bearer ${TOKEN}" \
     "https://api.github.com/repos/${OWNER}/${REPO}/branches/main/protection" \
     -d @branch-protection-full.json
   ```

   GitHub will respond with the updated protection object. If you prefer the GitHub CLI, the equivalent command is:

   ```bash
   gh api \
     --method PUT \
     -H "Accept: application/vnd.github+json" \
     "/repos/${OWNER}/${REPO}/branches/main/protection" \
     --input branch-protection-full.json
   ```

## Optional: Enable Auto-merge

To allow PRs that meet the protection rules to merge automatically:

1. Navigate to **Settings → General → Pull Requests**.
2. Enable **Allow auto-merge**.
3. Under **Merge button preferences**, enable **Allow squash merging** (recommended) and disable other merge methods if undesired.
4. Authors can then enable auto-merge on their PR once checks are queued; GitHub will complete the merge when both required checks pass.

## Verification Checklist

After applying the configuration:

- Open a test pull request against `main`.
- Confirm no review is requested; only the two required status checks should appear.
- (Optional) Enable auto-merge on the PR and verify it completes automatically when the checks succeed.
