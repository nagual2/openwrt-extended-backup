# Branch Protection Configuration

## Task 39: Reset Branch Protection to Minimal

This document tracks the branch protection configuration changes made to resolve PR merge blockers.

### Problem Statement

PRs are blocked by "waiting for required checks" due to stale or mismatched CI job names in the branch protection rules. To unblock PRs while CI is being stabilized (Task 38), we need to temporarily disable required status checks.

---

## Current State (Before Changes)

**Date:** 2024-10-27

### Previous Protection Settings

The `main` branch had the following protection rules (to be documented by admin with access):

- **Required status checks:** (List existing checks here)
- **Require branches to be up to date before merging:** (Yes/No)
- **Require pull request reviews:** (Count)
- **Other restrictions:** (List here)

> **Action Required:** An admin with repository access should document the exact current settings before making changes, so they can be restored later.

---

## Minimal Protection Configuration (Temporary)

To resolve merge blockers, apply these **temporary** settings:

### Settings to Keep

- ✅ **Require a pull request before merging**
  - Number of required approvals: `0` (no review count)
  - Dismiss stale pull request approvals when new commits are pushed: Optional
  
- ✅ **Do NOT allow force pushes**
  - Force pushes remain disabled

### Settings to Disable (Temporarily)

- ❌ **Required status checks:** DISABLE ALL
  - This removes the "waiting for required checks" blocker
  - Will be re-enabled after CI stabilizes

### Other Settings

- Keep existing settings for:
  - Required linear history (if applicable)
  - Include administrators (if applicable)
  - Restrict who can push to matching branches (if applicable)

---

## Implementation Steps

### Via GitHub UI

1. Navigate to **Settings → Branches** in the repository
2. Under "Branch protection rules", find the rule for `main`
3. Click **Edit** on the main branch protection rule
4. **BEFORE MAKING CHANGES:** Take screenshots or notes of all current settings
5. Locate the "Require status checks to pass before merging" section
6. **Uncheck** this option (or remove all individual checks)
7. Verify that:
   - "Require a pull request before merging" is **checked**
   - "Required number of approvals before merging" is set to `0`
   - "Do not allow bypassing the above settings" is **unchecked** (to allow force push restrictions to work)
8. Click **Save changes**

### Via GitHub API (For Automation)

```bash
# Set minimal protection with only PR requirement
curl -X PUT \
  -H "Authorization: token YOUR_ADMIN_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/nagual2/openwrt-extended-backup/branches/main/protection" \
  -d '{
    "required_status_checks": null,
    "enforce_admins": false,
    "required_pull_request_reviews": {
      "required_approving_review_count": 0
    },
    "restrictions": null,
    "allow_force_pushes": false,
    "allow_deletions": false
  }'
```

> **Note:** This requires a personal access token with `repo` scope and admin access to the repository.

---

## Verification

After applying the minimal protection:

1. ✅ PRs can be merged without waiting for status checks
2. ✅ PRs still require being opened (cannot push directly to main)
3. ✅ Force pushes to main are still blocked
4. ✅ No "waiting for required checks" blockers appear

---

## Re-enabling Protection (After Task 38)

Once Task 38 is merged and CI is stable with new working job names:

### Identify New CI Job Names

Check `.github/workflows/*.yml` files to find the updated job names. As of this writing, the workflow should define jobs like:

- `shellcheck`
- `test`
- Any other validation jobs

### Re-enable Required Status Checks

1. Return to **Settings → Branches → main → Edit**
2. Check "Require status checks to pass before merging"
3. In the search box, type the exact job names (e.g., `shellcheck`, `test`)
4. Select each job to add it to required checks
5. Optionally enable "Require branches to be up to date before merging"
6. Consider increasing "Required number of approvals before merging" if desired
7. Click **Save changes**

### Full Protection Settings (Recommended)

Once CI is stable, consider these enhanced settings:

```
- Require a pull request before merging: ✅
  - Required approving reviews: 1 (or more)
  - Dismiss stale reviews: ✅

- Require status checks to pass before merging: ✅
  - Required checks:
    - shellcheck
    - test
    - (Add others as needed)
  - Require branches to be up to date: ✅

- Do not allow force pushes: ✅
- Do not allow deletions: ✅
```

---

## Timeline

- **2024-10-27:** Task 39 - Minimal protection applied (status checks disabled)
- **TBD:** Task 38 merged, CI stabilized
- **TBD:** Full protection re-enabled with new CI job names

---

## References

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- Task 38: CI stabilization
- Task 39: Branch protection reset (this document)
