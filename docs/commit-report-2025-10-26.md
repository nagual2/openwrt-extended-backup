# Commit Report — 2025-10-26

Commits ahead of upstream (upstream/main → main): **104**

1. [`ffda633`](https://github.com/nagual2/openwrt-extended-backup/commit/ffda633b970aee3559165216039c2b78effedc6a) (2025-10-22) — CI — **ci(lint): add ShellCheck/shfmt GitHub Actions and fix script warnings** _(by engine-labs-app[bot])_
   - Integrates ShellCheck and shfmt checks into CI workflows to ensure coding standards and prevent shell scripting errors. Fixes all warnings in main scripts and sets up formatting guidelines.

2. [`2426fe8`](https://github.com/nagual2/openwrt-extended-backup/commit/
2426fe8c62baef1a30f51f93a3c7994f5eec5758) (2025-10-22) — Merge — **Merge pull request #1 from nagual2/ci/add-shellcheck-shfmt-workflow-fix-scripts-and-add-readme-badge** _(by Maksym)_
   - Add ShellCheck & shfmt CI, refactor scripts, fix warnings, update README with CI badge. [#1](https://github.com/nagual2/openwrt-extended-backup/pull/1)

3. [`08ade0e`](https://github.com/nagual2/openwrt-extended-backup/commit/
08ade0e107ecb3ba08bd9bac45c728d33ae192e3) (2025-10-22) — Docs — **docs(readme, restore): rewrite usage, SMB/ksmbd, restore, limits, tested OpenWrt** _(by engine-labs-app[bot])_
   - Update README to provide comprehensive guidance on using the backup scripts for OpenWrt.

4. [`ae89550`](https://github.com/nagual2/openwrt-extended-backup/commit/
ae89550729abb8eb7e48def6c480d7f7d03a1a2b) (2025-10-22) — Merge — **Merge pull request #2 from nagual2/docs/update-readme-usage-smb-ksmbd-restore-limits-tested-openwrt** _(by Maksym)_
   - Rewrite README and add restore guide. Usage, SMB/ksmbd, limitations, tested OpenWrt versions. [#2](https://github.com/nagual2/openwrt-extended-backup/pull/2)

5. [`86f48b9`](https://github.com/nagual2/openwrt-extended-backup/commit/
86f48b901621557ead97b072dceba2b8101ec556) (2025-10-22) — Feature — **feat(ci,build,versioning): add VERSION file, -V/--version flag, and automated GitHub Releases** _(by engine-labs-app[bot])_
   - This change introduces version management and automated release workflows.

6. [`1681aa2`](https://github.com/nagual2/openwrt-extended-backup/commit/
1681aa25e8a525b8d2f3ec470a723acd8c218994) (2025-10-23) — Merge — **Merge pull request #3 from nagual2/feat-versioning-add-v-flag-version-file-gh-actions-releases-changelog** _(by Maksym)_
   - Add version flag, VERSION file, and automated GitHub Releases. [#3](https://github.com/nagual2/openwrt-extended-backup/pull/3)

7. [`1291635`](https://github.com/nagual2/openwrt-extended-backup/commit/
12916355c1ce265e91d612d1ebba0bb714cbdc44) (2025-10-23) — Chore — **chore(main): release 0.5.0** _(by github-actions[bot])_
   - chore(main): release 0.5.0.

8. [`caaa209`](https://github.com/nagual2/openwrt-extended-backup/commit/
caaa2093900a4df94bf15b0f976ace8031db41c9) (2025-10-23) — Merge — **Merge pull request #4 from nagual2/release-please--branches--main** _(by Maksym)_
   - Chore(main). Release 0.5.0. [#4](https://github.com/nagual2/openwrt-extended-backup/pull/4)

9. [`3c264ee`](https://github.com/nagual2/openwrt-extended-backup/commit/
3c264eef41d61f53ad5a47d5a54d858fd8d00cea) (2025-10-23) — Feature — **feat(github): add pull request template for PR quality checks** _(by engine-labs-app[bot])_
   - Adds a PR template with a checklist to ensure all pull requests meet minimum requirements for description, OpenWrt testing, security considerations, safe cleanup, and BusyBox ash compatibility.

10. [`9d4fd19`](https://github.com/nagual2/openwrt-extended-backup/commit/
9d4fd19a659c923b9f23e8222a714faa8f2f04e0) (2025-10-23) — Feature — **feat(openwrt,build): add OpenWrt package/Makefile, .ipk build, and local Makefile** _(by engine-labs-app[bot])_
   - Adds an OpenWrt-compliant Makefile in the openwrt/ directory for building the package as a feed or manually with the OpenWrt SDK. Implements root Makefile for local .ipk packaging, allowing dependency toggling (e.g., ksmbd-tools).

11. [`d639363`](https://github.com/nagual2/openwrt-extended-backup/commit/
d63936314b35849bf3386f9796832f051444ec65) (2025-10-23) — Merge — **Merge pull request #5 from nagual2/smoke-test-add-pr-template-cto-labs-bot** _(by Maksym)_
   - Add PR template with checklist for quality and compatibility requirements. [#5](https://github.com/nagual2/openwrt-extended-backup/pull/5)

12. [`6e19f07`](https://github.com/nagual2/openwrt-extended-backup/commit/
6e19f076b92b34521309e5aa311487b99d983277) (2025-10-23) — Merge — **Merge pull request #6 from nagual2/feat/openwrt-extended-backup-ipk-makefile** _(by Maksym)_
   - Add OpenWrt .ipk packaging, Makefiles, and local build instructions. [#6](https://github.com/nagual2/openwrt-extended-backup/pull/6)

13. [`89b78a0`](https://github.com/nagual2/openwrt-extended-backup/commit/
89b78a043c326131bc8402d2d1e83c37a70f8006) (2025-10-23) — Chore — **chore(main): release 0.6.0** _(by github-actions[bot])_
   - chore(main): release 0.6.0.

14. [`347700d`](https://github.com/nagual2/openwrt-extended-backup/commit/
347700dad210ae74f4dfbcc54e5e3ab597cdbd56) (2025-10-23) — Merge — **Merge pull request #7 from nagual2/release-please--branches--main** _(by Maksym)_
   - Chore(main). Release 0.6.0. [#7](https://github.com/nagual2/openwrt-extended-backup/pull/7)

15. [`5f13cbc`](https://github.com/nagual2/openwrt-extended-backup/commit/
5f13cbc0d62596da480ba2f7701fd519f15e021a) (2025-10-23) — Feature — **feat(user_installed_packages): robust user package detection, commands, test, and docs** _(by engine-labs-app[bot])_
   - Improve detection of user-installed opkg packages for reliable rebuilds.

16. [`c91cdb4`](https://github.com/nagual2/openwrt-extended-backup/commit/
c91cdb456e3e57e9076875759e620244fe23d319) (2025-10-23) — Merge — **Merge remote-tracking branch 'origin/main' into feat/user-installed-packages** _(by nahual15)_
   - Merge remote-tracking branch 'origin/main' into feat/user-installed-packages.

17. [`41a3c91`](https://github.com/nagual2/openwrt-extended-backup/commit/
41a3c91039931f48fef0962dcfb567c2642d15dc) (2025-10-23) — Merge — **Merge branch 'feat/user-installed-packages'** _(by nahual15)_
   - Merge branch 'feat/user-installed-packages'.

18. [`defceb3`](https://github.com/nagual2/openwrt-extended-backup/commit/
defceb34737baea5a869592f10bc503dd5ce79ca) (2025-10-23) — Chore — **chore(main): release 0.7.0** _(by github-actions[bot])_
   - chore(main): release 0.7.0.

19. [`ec04c51`](https://github.com/nagual2/openwrt-extended-backup/commit/
ec04c518cebe3a91d5d3ce04890b7c344290ffa0) (2025-10-24) — Feature — **feat(restore): implement openwrt_full_restore utility with dry-run, safe file overwrites, and service restarts** _(by engine-labs-app[bot])_
   - Adds a robust shell script and packaging integration for openwrt_full_restore.

20. [`c6e88f4`](https://github.com/nagual2/openwrt-extended-backup/commit/
c6e88f4e13b9a78ac94ca56eb92daf384ffda158) (2025-10-24) — Merge — **Merge pull request #9 from nagual2/release-please--branches--main** _(by Maksym)_
   - Chore(main). Release 0.7.0. [#9](https://github.com/nagual2/openwrt-extended-backup/pull/9)

21. [`70044c1`](https://github.com/nagual2/openwrt-extended-backup/commit/
70044c18ba78336b8279e671b62f8ecda7a90e1f) (2025-10-24) — Merge — **Merge pull request #10 from nagual2/feat-openwrt-restore-dry-run-safe-overwrite** _(by Maksym)_
   - Add openwrt_full_restore utility for safe archive recovery, dry-run, package restore and automated service restarts. [#10](https://github.com/nagual2/openwrt-extended-backup/pull/10)

22. [`c864899`](https://github.com/nagual2/openwrt-extended-backup/commit/
c8648995c80ee216a199b1126c22adeb6d4695d0) (2025-10-24) — Docs — **docs(assessment): add comprehensive repo audit and prioritized roadmap** _(by engine-labs-app[bot])_
   - Add `docs/assessment.md` report with review of core scripts, security, dependencies, and UX issues for openwrt-extended-backup. Identify key technical debts, POSIX and packaging gaps, as well as safety and automation risks.

23. [`30d947a`](https://github.com/nagual2/openwrt-extended-backup/commit/
30d947af2e5d5b6a6f7160d97bc6058211c5ae2f) (2025-10-24) — Merge — **Merge pull request #11 from nagual2/audit-openwrt-extended-backup-plan** _(by Maksym)_
   - Add initial assessment, roadmap, and draft tasks for openwrt-extended-backup audit. [#11](https://github.com/nagual2/openwrt-extended-backup/pull/11)

24. [`21653d8`](https://github.com/nagual2/openwrt-extended-backup/commit/
21653d8db8f413590fc3548096eb777a27f7e360) (2025-10-24) — Feature — **feat(backup): default to SCP export, new CLI flags, and robust SMB handling** _(by engine-labs-app[bot])_
   - Refactor openwrt_full_backup to default to SCP-based export with a generated scp command for easy download, eliminating SMB dependency by default. Add CLI flags.

25. [`3e3e164`](https://github.com/nagual2/openwrt-extended-backup/commit/
3e3e16493873eace7a5c0e21290eed6e66e2a6ff) (2025-10-24) — Merge — **Merge pull request #12 from nagual2/feat-openwrt-full-backup-scp-default-cli-flags** _(by Maksym)_
   - SCP by default, modular CLI export modes, improved logging and SMB safety. [#12](https://github.com/nagual2/openwrt-extended-backup/pull/12)

26. [`9331cf8`](https://github.com/nagual2/openwrt-extended-backup/commit/
9331cf8c41adf1142eb56e1d828eb2811bb0cb75) (2025-10-24) — Chore — **chore(main): release 0.8.0** _(by github-actions[bot])_
   - chore(main): release 0.8.0.

27. [`979e8e1`](https://github.com/nagual2/openwrt-extended-backup/commit/
979e8e15799f0fb44b842998e5e517ab7664b483) (2025-10-24) — CI — **ci(shell): add GitHub Actions workflow for shellcheck, shfmt, and shell quality checks** _(by engine-labs-app[bot])_
   - Introduce a comprehensive shell quality workflow for shell scripts on push/PR. Add shell-quality.yml workflow.

28. [`c2a9545`](https://github.com/nagual2/openwrt-extended-backup/commit/
c2a95457873ef8dca68b5926be958f7d213ff783) (2025-10-24) — Merge — **Merge pull request #14 from nagual2/ci-shellcheck-shfmt-basic-checks-readme-badge** _(by cto-new[bot])_
   - Add shellcheck, shfmt, unified shell quality workflow & README badge. [#14](https://github.com/nagual2/openwrt-extended-backup/pull/14)

29. [`e4523b4`](https://github.com/nagual2/openwrt-extended-backup/commit/
e4523b423feb5c75b970e2920247db726cdfa533) (2025-10-24) — Merge — **Merge pull request #13 from nagual2/release-please--branches--main** _(by Maksym)_
   - Chore(main). Release 0.8.0. [#13](https://github.com/nagual2/openwrt-extended-backup/pull/13)

30. [`2005858`](https://github.com/nagual2/openwrt-extended-backup/commit/
2005858379410d8a7c7089e57b0a3572ea9095f7) (2025-10-24) — Bug Fix — **fix(user_installed_packages): rewrite to produce correct deterministic package list** _(by engine-labs-app[bot])_
   - Rewrite the user_installed_packages script to correctly parse opkg status files, handle user-provided lists, and honor exclude/include flags as expected. This change ensures the output matches test fixtures and README documentation.

31. [`8efaab2`](https://github.com/nagual2/openwrt-extended-backup/commit/
8efaab2a716b896eff5aceae388644ef019b31e5) (2025-10-24) — Merge — **Merge pull request #15 from nagual2/feat-continuation** _(by cto-new[bot])_
   - Fix and enhance user_installed_packages script for correct package list generation. [#15](https://github.com/nagual2/openwrt-extended-backup/pull/15)

32. [`c2cbe66`](https://github.com/nagual2/openwrt-extended-backup/commit/
c2cbe66289b5cd190cd4f63d3b5df597bfd67f92) (2025-10-24) — Chore — **chore(main): release 0.8.1** _(by github-actions[bot])_
   - chore(main): release 0.8.1.

33. [`5ec890c`](https://github.com/nagual2/openwrt-extended-backup/commit/
5ec890cee59ac26600acdd9198a364d53f365828) (2025-10-24) — Merge — **Merge pull request #16 from nagual2/release-please--branches--main** _(by Maksym)_
   - Chore(main). Release 0.8.1. [#16](https://github.com/nagual2/openwrt-extended-backup/pull/16)

34. [`1f327a0`](https://github.com/nagual2/openwrt-extended-backup/commit/
1f327a0f819f1f07d8a8e01e43b532b3f4dfe5ad) (2025-10-24) — Bug Fix — **fix(ci): restore and stabilize shell script CI workflows** _(by engine-labs-app[bot])_
   - Restore green CI on main branch by reworking shell quality workflows and fixing compatibility issues.

35. [`77c04e5`](https://github.com/nagual2/openwrt-extended-backup/commit/
77c04e5097a1b552fe9a22ce4ab241dd0f8d03ba) (2025-10-24) — Merge — **Merge pull request #17 from nagual2/fix-ci-main-github-actions-shellcheck-shfmt-openwrt** _(by cto-new[bot])_
   - Fix/main. Restore green CI and ensure shell script compatibility (shfmt, shellcheck). [#17](https://github.com/nagual2/openwrt-extended-backup/pull/17)

36. [`3c952f0`](https://github.com/nagual2/openwrt-extended-backup/commit/
3c952f02ee77ebdd2cd891f4bbf34d2211fb66b4) (2025-10-24) — Chore — **chore(main): release 0.8.2** _(by github-actions[bot])_
   - chore(main): release 0.8.2.

37. [`75b13ad`](https://github.com/nagual2/openwrt-extended-backup/commit/
75b13ad1010852015ebf8db4997e14f686c48af4) (2025-10-24) — Merge — **Merge pull request #18 from nagual2/release-please--branches--main** _(by Maksym)_
   - Chore(main). Release 0.8.2. [#18](https://github.com/nagual2/openwrt-extended-backup/pull/18)

38. [`e9ed122`](https://github.com/nagual2/openwrt-extended-backup/commit/
e9ed122cbbe9927c7ad590082935fbb9f30304bc) (2025-10-24) — CI — **ci(main): fix and stabilize CI workflows and shell quality checks** _(by engine-labs-app[bot])_
   - Fixes broken main branch CI by updating workflow YAMLs and script compatibility.

39. [`d4d1119`](https://github.com/nagual2/openwrt-extended-backup/commit/
d4d1119ba9e7023943a38d8421138a1624b638d7) (2025-10-24) — Merge — **Merge pull request #19 from nagual2/fix-ci-main-recreate** _(by cto-new[bot])_
   - Fix and stabilize CI on main branch, improve shell scripts compatibility. [#19](https://github.com/nagual2/openwrt-extended-backup/pull/19)

40. [`6c4a3d7`](https://github.com/nagual2/openwrt-extended-backup/commit/
6c4a3d70b25e6c175757f29e329f0a7980015403) (2025-10-24) — CI — **ci(workflows): hotfix GitHub Actions, pin action SHAs, stabilize shell tooling** _(by engine-labs-app[bot])_
   - CI was failing due to missing shfmt on Ubuntu 22.04 and unpinned action dependencies, leading to unstable builds and potential supply chain risks. This change addresses these issues to restore green CI and improve security and reliability.

41. [`bd45dba`](https://github.com/nagual2/openwrt-extended-backup/commit/
bd45dba999ecfcb37fb0debfa4571ca480368b53) (2025-10-24) — Merge — **Merge pull request #21 from nagual2/ci-hotfix-recreate-fix-gh-actions** _(by cto-new[bot])_
   - Hotfix to stabilize GitHub Actions and shell quality checks, pin action SHAs. [#21](https://github.com/nagual2/openwrt-extended-backup/pull/21)

42. [`303baff`](https://github.com/nagual2/openwrt-extended-backup/commit/
303baff9389171da3e9e7a25160557cd6669817c) (2025-10-24) — CI — **ci(workflows): pin action versions, add concurrency, artifact reports, and tool cache** _(by engine-labs-app[bot])_
   - This update strengthens CI reproducibility and efficiency.

43. [`35e9da9`](https://github.com/nagual2/openwrt-extended-backup/commit/
35e9da963db39f11de5f7dc39dc1699487a0ecea) (2025-10-24) — Merge — **Merge pull request #22 from nagual2/ci/pin-actions-by-sha-add-concurrency-artifacts-cache-cleanup-update-readme-badge** _(by cto-new[bot])_
   - Pin action SHAs, add concurrency, caching, granular artifacts, and update badge. [#22](https://github.com/nagual2/openwrt-extended-backup/pull/22)

44. [`2280d04`](https://github.com/nagual2/openwrt-extended-backup/commit/
2280d045b91bf1b2a309b8ee0e1b04e737e17469) (2025-10-24) — Bug Fix — **fix(ci): resolve CI failure by pinning shfmt to compatible version** _(by engine-labs-app[bot])_
   - Main CI workflow was failing due to incompatibility with the latest shfmt release. This hotfix pins shfmt to version 3.8.0 with the correct SHA256, restoring reliable CI in main.

45. [`dbf93f1`](https://github.com/nagual2/openwrt-extended-backup/commit/
dbf93f1f2070259e2b4059cde7aedb0a1387058e) (2025-10-24) — Merge — **Merge pull request #23 from nagual2/ci-hotfix-failing-main-workflow** _(by cto-new[bot])_
   - CI hotfix. Pin shfmt to v3.8.0 to resolve workflow failures in main. [#23](https://github.com/nagual2/openwrt-extended-backup/pull/23)

46. [`7bf7e12`](https://github.com/nagual2/openwrt-extended-backup/commit/
7bf7e125f19c39fe21eb899092d28a9c4aa155a9) (2025-10-24) — Chore — **chore(main): release 0.8.3** _(by github-actions[bot])_
   - chore(main): release 0.8.3.

47. [`9c3e085`](https://github.com/nagual2/openwrt-extended-backup/commit/
9c3e0859f5ad905b0576a956676858b430955e28) (2025-10-25) — Merge — **Merge pull request #24 from nagual2/release-please--branches--main** _(by Maksym)_
   - Chore(main). Release 0.8.3. [#24](https://github.com/nagual2/openwrt-extended-backup/pull/24)

48. [`c178720`](https://github.com/nagual2/openwrt-extended-backup/commit/
c1787200b16fd84bddb979cfd6edd2dc6377469b) (2025-10-24) — CI — **ci(main): pin action versions, concurrency and CI robustness improvements** _(by engine-labs-app[bot])_
   - CI robustness has been improved following a hotfix.

49. [`ceb5eb0`](https://github.com/nagual2/openwrt-extended-backup/commit/
ceb5eb0e225ce2e9d957f49ee96e304be698d595) (2025-10-24) — Merge — **Merge pull request #26 from nagual2/post-hotfix-ci-pin-actions-sha-concurrency-main-shellcheck-shfmt-reports-cache-cleanup-update-readme-badge** _(by cto-new[bot])_
   - Pin actions by SHA, add concurrency, robust cache for tools, and clarify CI badge. [#26](https://github.com/nagual2/openwrt-extended-backup/pull/26)

50. [`837050b`](https://github.com/nagual2/openwrt-extended-backup/commit/
837050b6f338286cb2a665f24dfdaa4585b5bf60) (2025-10-24) — Docs — **docs(contributing): document trunk branch, branching policy, and CI rules** _(by engine-labs-app[bot])_
   - Add CONTRIBUTING.md with trunk branch identified as `main`, a standardized branch naming policy, and detailed PR workflow requirements. Outline local validation against the Shell quality CI check before PR.

51. [`693a35f`](https://github.com/nagual2/openwrt-extended-backup/commit/
693a35f6edc74d7d9e535fb0e9c1ccd2dcddb963) (2025-10-25) — Merge — **Merge pull request #27 from nagual2/chore/trunk-protection-merge-order-branch-cleanup** _(by Maksym)_
   - Add contribution policy, branch naming conventions, and CI requirements. [#27](https://github.com/nagual2/openwrt-extended-backup/pull/27)

52. [`0d02d78`](https://github.com/nagual2/openwrt-extended-backup/commit/
0d02d78cff0e39c96b4a984f11943298bbe7a473) (2025-10-25) — Docs — **docs: add project management documentation and cleanup** _(by nahual15)_
   - Add branch protection documentation and configuration files Add completion reports for trunk management and branch merging tasks Update CONTRIBUTING.md with current branch protection status Remove accidentally created diff artifact file.

53. [`f8846ff`](https://github.com/nagual2/openwrt-extended-backup/commit/
f8846ff5887c931d38a2225450e106742adbb499) (2025-10-25) — CI — **ci(release): switch to tag-based release automation and remove release-please assets** _(by engine-labs-app[bot])_
   - Switches the release workflow to trigger on git tags matching 'v*', replacing release-please automation.

54. [`240eedb`](https://github.com/nagual2/openwrt-extended-backup/commit/
240eedb652733c0777e4c9cadb4bf2eb324808f3) (2025-10-25) — Docs — **docs: rewrite README and add Keep a Changelog-compliant CHANGELOG for v0.1.0** _(by engine-labs-app[bot])_
   - Rewrite the top of the README in English with a new CI badge, explicit runtime requirements, and concise installation and usage sections for both distributed scripts, including updated usage examples. Add and document a new development section detailing `shfmt` checks and `bats` tests for local CI parity.

55. [`899013a`](https://github.com/nagual2/openwrt-extended-backup/commit/
899013a742d4e9a36252a4b46381d4ca289ef215) (2025-10-25) — CI — **ci(github-actions): add unified CI workflow, remove legacy QA scripts** _(by engine-labs-app[bot])_
   - Replace the legacy shell-quality workflow and associated scripts with a modern GitHub Actions pipeline for shell script QA and testing. This ensures consistency, avoids duplication, and simplifies maintenance.

56. [`977b46c`](https://github.com/nagual2/openwrt-extended-backup/commit/
977b46c33be6c1707b0ab7e6eedea695447078a6) (2025-10-25) — Test — **test(tests): add Bats test suite and advanced shell mocks for backup/package scripts** _(by engine-labs-app[bot])_
   - Adds a structured Bats test framework to improve confidence and prevent regressions.

57. [`f7de548`](https://github.com/nagual2/openwrt-extended-backup/commit/
f7de548842a6da36cdbbc5dac7b21b7c614d56f5) (2025-10-25) — Feature — **feat(backup): harden OpenWrt backup scripts, improve testability, and unify formatting** _(by engine-labs-app[bot])_
   - This change introduces multiple reliability and maintainability improvements for the OpenWrt full backup toolkit.

58. [`9ccd1f1`](https://github.com/nagual2/openwrt-extended-backup/commit/
9ccd1f10c23044107b8a32467241f5fcac7c206f) (2025-10-25) — Chore — **chore(release): prepare v0.1.0 initial release configs** _(by engine-labs-app[bot])_
   - Align repository state and scripts for v0.1.0 public release.

59. [`78fd807`](https://github.com/nagual2/openwrt-extended-backup/commit/
78fd807de6926a478b50e84dd7712e64b11181a5) (2025-10-25) — Chore — **chore(release): prepare v0.1.0 initial release, version, and changelog** _(by engine-labs-app[bot])_
   - This change sets up the repository for the first public release by updating version metadata, script fallbacks, and release configuration. This ensures a consistent version surface for all distributed artifacts, both in scripts and release automation.

60. [`b025816`](https://github.com/nagual2/openwrt-extended-backup/commit/
b02581682111a1598dc2feb30ef1fd538a01697f) (2025-10-25) — CI — **ci(release): add post-release artifact verification workflow** _(by engine-labs-app[bot])_
   - Adds an automated GitHub Actions workflow to verify release artifacts after each release is published. This ensures that checksums, asset presence, script functionality, and version consistency are validated before end users access artifacts.

61. [`734b8cd`](https://github.com/nagual2/openwrt-extended-backup/commit/
734b8cd48afdf849e5c15607af6f44bdad7b87c9) (2025-10-25) — Test — **test(bats): add full negative/edge-path bats-core test coverage for backup and package scripts** _(by engine-labs-app[bot])_
   - Increase script reliability and error-path confidence by migrating and expanding tests to bats-core. Add golden-output and failure-path assertions for openwrt_full_backup and user_installed_packages.

62. [`921a6fd`](https://github.com/nagual2/openwrt-extended-backup/commit/
921a6fd3d80f045d6f873047dbe055cd909359bf) (2025-10-25) — CI — **ci(shell-matrix): add CI matrix for dash and busybox ash shells** _(by engine-labs-app[bot])_
   - Broaden CI to better mimic OpenWrt environments and detect shell-specific script issues.

63. [`d459862`](https://github.com/nagual2/openwrt-extended-backup/commit/
d4598628cd48813260b148b94377b0f729b293b7) (2025-10-25) — Feature — **feat(backup): add dry-run mode and --output option to openwrt_full_backup** _(by engine-labs-app[bot])_
   - Adds a dry-run mode (via -n/--dry-run flag or DRY_RUN env var) and a new --output option to openwrt_full_backup, improving usability and scripting flexibility.

64. [`0eb76a3`](https://github.com/nagual2/openwrt-extended-backup/commit/
0eb76a3ad9e163dc17db39fb13921a69dc64f3b0) (2025-10-25) — Bug Fix — **fix(scripts): robust error handling and cleanup in backup/restore scripts** _(by engine-labs-app[bot])_
   - Improve robustness and reliability of openwrt_full_backup, openwrt_full_restore, and user_installed_packages scripts:.

65. [`47d4d1a`](https://github.com/nagual2/openwrt-extended-backup/commit/
47d4d1ad53ec2a5a977fdcd9cb040324a277db51) (2025-10-25) — CI — **ci(makefile): add Makefile targets and unify local/CI shell checks and tests** _(by engine-labs-app[bot])_
   - This change introduces a Makefile to simplify local development and CI by providing a unified interface for formatting, linting, and testing shell scripts.

66. [`3f96179`](https://github.com/nagual2/openwrt-extended-backup/commit/
3f96179221e5ef5a6d98fbb7dacce55117c116fb) (2025-10-25) — Feature — **feat(user_installed_packages): add --output, --format, and enhance filters** _(by engine-labs-app[bot])_
   - Adds --output <file> for writing output to a file, and --format {opkg,plain} to allow toggling between opkg-style and plain list output. Introduces support for --exclude PATTERN (glob), now also available via --exclude and multiple -x.

67. [`4f5edb3`](https://github.com/nagual2/openwrt-extended-backup/commit/
4f5edb3475eb63d2580f1f9e63d2e3ead5a4a699) (2025-10-25) — Feature — **feat(helpers): add install/uninstall scripts with BATS tests** _(by engine-labs-app[bot])_
   - Adds POSIX-compliant installer and uninstaller scripts for project shell helpers. Includes BATS tests to verify install/uninstall logic using a temporary prefix for safe, rootless testing.

68. [`0edb39e`](https://github.com/nagual2/openwrt-extended-backup/commit/
0edb39e4227e969061e706c58f5989e6df103ee6) (2025-10-25) — Feature — **feat(release): add release bump helper script and update docs** _(by engine-labs-app[bot])_
   - Introduce scripts/release.sh for automated local version bump and tag prep.

69. [`c4892e5`](https://github.com/nagual2/openwrt-extended-backup/commit/
c4892e57902fed733f8875c304042676ef286ee2) (2025-10-25) — Feature — **feat(restore): add openwrt_restore script with snapshot, safe restore, package reinstall, and tests** _(by engine-labs-app[bot])_
   - Adds the new POSIX sh-compatible `openwrt_restore` script. This script validates OpenWrt environment, checks archive integrity (incl.

70. [`635a292`](https://github.com/nagual2/openwrt-extended-backup/commit/
635a2926b469fa65dece8d1348948182d2f652e7) (2025-10-26) — Feature — **feat(backup): add SCP/SFTP upload for remote backup export** _(by engine-labs-app[bot])_
   - This adds remote upload features to openwrt_full_backup, allowing archives created on OpenWrt devices to be uploaded directly to remote hosts via SCP or SFTP. This enables automated off-device backup retention and improves data safety.

71. [`f5073ac`](https://github.com/nagual2/openwrt-extended-backup/commit/
f5073acbea2fdeacf16e09254b064aa851f0ec25) (2025-10-26) — Feature — **feat(ci,build): add OpenWrt .ipk packaging, multi-target CI, and publish feed metadata** _(by engine-labs-app[bot])_
   - Adds OpenWrt-compliant packaging for the backup/restore toolkit with proper deps, install locations, and docs.

72. [`e192349`](https://github.com/nagual2/openwrt-extended-backup/commit/
e1923494515ba8f449cf35c8d5a689beb7db1df8) (2025-10-26) — CI — **ci(e2e): add QEMU-based OpenWrt end-to-end CI for backup flow** _(by engine-labs-app[bot])_
   - Introduce a GitHub Actions workflow that runs full end-to-end tests of backup scripts inside a real OpenWrt QEMU VM. This change ensures that the backup logic is validated in an environment that closely mimics actual OpenWrt devices.

73. [`4e9fa2a`](https://github.com/nagual2/openwrt-extended-backup/commit/
4e9fa2a99dda9abb6bfbd8c7888bdd9cf8f0e364) (2025-10-26) — Feature — **feat(release): prepare v0.2.0 with restore, remote upload, .ipk packaging, and E2E tests** _(by engine-labs-app[bot])_
   - This change aggregates updates for the 0.2.0 minor release.

74. [`0ecbb9b`](https://github.com/nagual2/openwrt-extended-backup/commit/
0ecbb9bbf173d20f54593f3be04084d5ce791c2e) (2025-10-26) — Merge — **Merge remote-tracking branch 'origin/docs-revise-readme-add-changelog-v0.1.0' into merge-tasks-1-15-into-main-e01** _(by engine-labs-app[bot])_
   - # Conflicts. # CHANGELOG.md # README.md.

75. [`a509c50`](https://github.com/nagual2/openwrt-extended-backup/commit/
a509c50739205311253fc3ab8628dc0513e59cbe) (2025-10-26) — Merge — **Merge remote-tracking branch 'origin/ci/add-ci-workflow-remove-legacy-scripts' into merge-tasks-1-15-into-main-e01** _(by engine-labs-app[bot])_
   - # Conflicts. # README.md.

76. [`d9b1e01`](https://github.com/nagual2/openwrt-extended-backup/commit/
d9b1e016e030e774e6d2e1b617e85d401a94d187) (2025-10-26) — Merge — **Merge remote-tracking branch 'origin/test/add-bats-tests-mocks-fixtures' into merge-tasks-1-15-into-main-e01** _(by engine-labs-app[bot])_
   - Merge remote-tracking branch 'origin/test/add-bats-tests-mocks-fixtures' into merge-tasks-1-15-into-main-e01.

77. [`00e9835`](https://github.com/nagual2/openwrt-extended-backup/commit/
00e9835954b39f5981ac6f296a2b0bd4d65c3ce9) (2025-10-26) — Merge — **merge(main): consolidate tasks 1–15 and feature branches into main with conflict resolution** _(by engine-labs-app[bot])_
   - This change merges the completed work for tasks 1–15 into the main branch to unify all critical features, fixes, and CI improvements.

78. [`71aac37`](https://github.com/nagual2/openwrt-extended-backup/commit/
71aac3702f2454a0ad20021c018aca5b6c6492b2) (2025-10-26) — Feature — **feat(ci): publish signed opkg feed to GitHub Pages on release tag** _(by engine-labs-app[bot])_
   - Adds workflow to publish .ipk and opkg feed for openwrt-extended-backup via GitHub Pages on release tag push. Feed publishing is automated and includes optional package index signing via usign.

79. [`8d0039f`](https://github.com/nagual2/openwrt-extended-backup/commit/
8d0039fd094e41bee11ba01bfa6ca442a0b503ff) (2025-10-26) — Chore — **chore(repo): enforce branch protection, clean feature branches, and require CODEOWNERS review** _(by engine-labs-app[bot])_
   - Tighten repository workflow and protection to ensure high integrity of releases and codebase. Require PRs to main with two required CI checks.

80. [`42f6390`](https://github.com/nagual2/openwrt-extended-backup/commit/
42f639063c3d729528bb6d394db2c21820c0b694) (2025-10-26) — Docs — **docs: rewrite README and add Keep a Changelog-compliant CHANGELOG for v0.1.0** _(by nahual15)_
   - docs: rewrite README and add Keep a Changelog-compliant CHANGELOG for v0.1.0.

81. [`9360359`](https://github.com/nagual2/openwrt-extended-backup/commit/
936035948a862e23b400c37f8212758c8bbd94b1) (2025-10-26) — Feature — **feat(backup): add SCP/SFTP upload for remote backup export** _(by nahual15)_
   - Resolve merge conflict in README.md by accepting the updated version.

82. [`8748f51`](https://github.com/nagual2/openwrt-extended-backup/commit/
8748f519c275aab71b816cc51938c3a46e6d604b) (2025-10-26) — Feature — **feat(helpers): add install/uninstall scripts with BATS tests** _(by nahual15)_
   - feat(helpers): add install/uninstall scripts with BATS tests.

83. [`2047ca6`](https://github.com/nagual2/openwrt-extended-backup/commit/
2047ca675f1a9db4106fa94a7c7fc37c70ae900c) (2025-10-26) — Feature — **feat(backup): add dry-run output tests and validation** _(by nahual15)_
   - Resolve merge conflicts by accepting the enhanced dry-run functionality.

84. [`bbba9ff`](https://github.com/nagual2/openwrt-extended-backup/commit/
bbba9ff77eea2d48cbf38806a3ec15161faced42) (2025-10-26) — Feature — **feat(ci): publish signed opkg feed to GitHub Pages on release tag** _(by nahual15)_
   - feat(ci): publish signed opkg feed to GitHub Pages on release tag.

85. [`1b36e8b`](https://github.com/nagual2/openwrt-extended-backup/commit/
1b36e8bc356c3f5287a09ebbe7d6a7f4af58296e) (2025-10-26) — Chore — **chore(main): release 0.9.0** _(by github-actions[bot])_
   - chore(main): release 0.9.0.

86. [`d5b4170`](https://github.com/nagual2/openwrt-extended-backup/commit/
d5b4170439f050791a6670903963ef727d465f7e) (2025-10-26) — Feature — **feat(user_installed_packages): add --output, --format options and exclude functionality** _(by nahual15)_
   - feat(user_installed_packages): add --output, --format options and exclude functionality.

87. [`f468a6b`](https://github.com/nagual2/openwrt-extended-backup/commit/
f468a6b68383c69652a69f435aeaa1404c2c44af) (2025-10-26) — Feature — **feat(ci): add tagged release workflow with GitHub releases** _(by nahual15)_
   - Resolve merge conflict in CHANGELOG.md by accepting the updated version.

88. [`e164076`](https://github.com/nagual2/openwrt-extended-backup/commit/
e164076682e0fadf08999c2d27a84b0f1f528b41) (2025-10-26) — Feature — **feat(release): add version bump helper scripts and automation** _(by nahual15)_
   - Resolve merge conflict in CONTRIBUTING.md.

89. [`ccd1a00`](https://github.com/nagual2/openwrt-extended-backup/commit/
ccd1a00550e7f93ed55c893ecd584a68abd884ac) (2025-10-26) — Chore — **chore(ci): add Makefile targets for CI automation** _(by nahual15)_
   - Resolve merge conflicts by accepting improved bats installation.

90. [`a61f603`](https://github.com/nagual2/openwrt-extended-backup/commit/
a61f603408573fd089b3ad278dab20c6c8f3a4a2) (2025-10-26) — Feature — **feat(restore): implement OpenWrt restore functionality with safety checks** _(by nahual15)_
   - Resolve merge conflict in README.md.

91. [`8bd75ee`](https://github.com/nagual2/openwrt-extended-backup/commit/
8bd75ee5e3ff4c2683d701aaa73146ba2527bd89) (2025-10-26) — Test — **test(tests): add BATS test mocks and fixtures** _(by nahual15)_
   - Resolve merge conflict in tests/openwrt_full_backup.bats by keeping the complete version.

92. [`9455c88`](https://github.com/nagual2/openwrt-extended-backup/commit/
9455c8848fa23746f8701c1a21f31aef59ac6a48) (2025-10-26) — Feature — **feat(packaging): implement OpenWrt IPK package creation and management** _(by nahual15)_
   - Resolve merge conflict in Makefile.

93. [`89c0994`](https://github.com/nagual2/openwrt-extended-backup/commit/
89c0994711e73e39f8dadaf7c95f2015f6069776) (2025-10-26) — Feature — **feat(ci): add end-to-end OpenWrt QEMU CI testing** _(by nahual15)_
   - feat(ci): add end-to-end OpenWrt QEMU CI testing.

94. [`f2ae048`](https://github.com/nagual2/openwrt-extended-backup/commit/
f2ae0481dbcf65695a745c14870ae2dd1161065f) (2025-10-26) — Feature — **feat(ci): add shell matrix testing for dash and busybox ash** _(by nahual15)_
   - feat(ci): add shell matrix testing for dash and busybox ash.

95. [`2af0038`](https://github.com/nagual2/openwrt-extended-backup/commit/
2af0038e9ba08cf4d624213b7510658ec0a74491) (2025-10-26) — Test — **test(coverage): add BATS coverage for opkg backup user packages** _(by nahual15)_
   - Resolve merge conflicts by keeping complete test suites.

96. [`1eece55`](https://github.com/nagual2/openwrt-extended-backup/commit/
1eece556580a46c5fe6da3189dcf7b12fb291183) (2025-10-26) — Feature — **feat(integration): merge tasks 1-15 into main with conflict resolution** _(by nahual15)_
   - This commit consolidates multiple feature branches and improvements.

97. [`f777c5a`](https://github.com/nagual2/openwrt-extended-backup/commit/
f777c5ab570e99fa269854e1cd22adfc4d99e7be) (2025-10-26) — Chore — **chore(scripts): enhance error handling and cleanup in shell scripts** _(by nahual15)_
   - Resolve merge conflicts by accepting the enhanced error handling.

98. [`e9e52c4`](https://github.com/nagual2/openwrt-extended-backup/commit/
e9e52c44a4dc90d30cc75e73c42038233526b095) (2025-10-26) — Chore — **chore(repo): add branch protection and main branch cleanup** _(by nahual15)_
   - Resolve merge conflicts by accepting the enhanced protection rules.

99. [`ab2734e`](https://github.com/nagual2/openwrt-extended-backup/commit/
ab2734e93f7d87df120a0176796b809fd18448a1) (2025-10-26) — Chore — **chore(ci): add post-release verification workflow** _(by nahual15)_
   - Resolve merge conflict by accepting the new workflow.

100. [`6788fc5`](https://github.com/nagual2/openwrt-extended-backup/commit/
6788fc5d28ebba2ba8fe7194c9e4fb34903bdb8a) (2025-10-26) — Feature — **feat(release): v0.1.0 PR review, build IPK and opkg feed** _(by nahual15)_
   - Resolve merge conflicts by accepting the release versions.

101. [`42f1040`](https://github.com/nagual2/openwrt-extended-backup/commit/
42f1040203fa461c94378991df2cfb8542a8ae37) (2025-10-26) — Feature — **feat(release): v0.1.0 publish workflow and documentation** _(by nahual15)_
   - Resolve merge conflicts by accepting the release configuration.

102. [`afa58c4`](https://github.com/nagual2/openwrt-extended-backup/commit/
afa58c474ba409e27b53b3e01b12916c569a7975) (2025-10-26) — Feature — **feat(release): v0.2.0 release with ticket-15 integration** _(by nahual15)_
   - This major release includes. Enhanced backup and restore functionality Improved user package management Updated documentation and changelog Release automation improvements Version bump to v0.2.0.

103. [`520b797`](https://github.com/nagual2/openwrt-extended-backup/commit/
520b7974b024c93fe00fbf7933d121405acdbe09) (2025-10-26) — Chore — **chore(release): bump version to 0.4.1** _(by nahual15)_
   - Automatic version update from release-please integration.

104. [`a36778d`](https://github.com/nagual2/openwrt-extended-backup/commit/
a36778df7a85f073d26a8e5eaf5a84b2c07fdf7a) (2025-10-26) — Chore — **chore(main): release 0.9.0** _(by nahual15)_
   - Merge release-please automatic release PR.
