# Branch Protection Settings Applied

The following branch protection settings have been configured for the `main` branch:

## Protection Rules Applied:
- **Required pull request reviews**: ✅ Enabled
  - Reviews required before merging: Yes
  - Dismiss stale reviews: Yes
  - Require code owner reviews: No

- **Required status checks**: ✅ Configured
  - Shell quality checks required
  - CI workflows must pass

- **Branch restrictions**: ✅ Configured
  - Force pushes: Disabled
  - Deletions: Disabled
  - Linear history: Not enforced

- **Admin enforcement**: ✅ Disabled
  - Repository administrators are not exempt from protection rules

## CI Requirements:
The following CI checks are required before merging:
- **shell-quality** workflow: Must pass
- All shell scripts must pass linting (shellcheck, shfmt)
- Code quality standards must be met

## Branch Naming Convention:
- Feature branches: `feat/feature-name`
- Bug fixes: `fix/issue-description`
- Hotfixes: `hotfix/issue-description`
- Releases: `release/vX.Y.Z`
- CI/Documentation: `ci/*`, `docs/*`, `chore/*`

## Auto-deletion:
- Branches are automatically deleted after PR merge
- No manual cleanup required for merged branches
