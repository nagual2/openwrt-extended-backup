# Vendored shell tooling

This directory provides the prebuilt executables that drive the repository's
`shell quality` continuous integration job.  The artifacts are vendored so that
CI can run without performing any network downloads.

## Tool inventory

### shfmt
- Version: [v3.12.0](https://github.com/mvdan/sh/releases/tag/v3.12.0) (linux-amd64 release asset `shfmt_v3.12.0_linux_amd64`)
- License: [BSD 3-Clause](LICENSES/shfmt)
- Entrypoint: `tools/shfmt`

### ShellCheck
- Version: [v0.11.0](https://github.com/koalaman/shellcheck/releases/tag/v0.11.0) (linux x86_64 static build)
- License: [GNU GPL v3](LICENSES/shellcheck)
- Entrypoint: `tools/shellcheck`

### bats-core
- Version: [v1.12.0](https://github.com/bats-core/bats-core/releases/tag/v1.12.0)
- License: [MIT](bats-core/LICENSE.md)
- Entrypoint: `tools/bats-core/bin/bats`

## Local development

By default the Makefile targets use these vendored tools.  Developers who prefer
system installed utilities can opt in by setting `USE_SYSTEM_TOOLS=1`, for
example:

```
USE_SYSTEM_TOOLS=1 make lint
```

When updating to newer versions of any tool, download the release artifacts for
linux-amd64, replace the files in this directory, and update version references
in this document and the CI workflow accordingly.
