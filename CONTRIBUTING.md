# Contributing to openwrt-extended-backup

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Code of Conduct

Please be respectful and constructive in all interactions.

## Security First

**IMPORTANT: Security is a top priority.** Before contributing, please read [SECURITY.md](./SECURITY.md).

### Critical Security Rules

1. **Never commit credentials or secrets:**
   - API keys, GitHub tokens, SSH private keys
   - Passwords (use test values or environment variables instead)
   - AWS credentials or other cloud secrets
   - Any personally identifiable information

2. **Use SSH for git operations:**
   - Configure git to use SSH: `git clone git@github.com:...`
   - Do NOT use HTTPS with embedded credentials

3. **Protect sensitive data:**
   - Store credentials in `.env` files (add to `.gitignore`)
   - Use environment variables in tests
   - Reference `.env.example` for test setup

4. **Test credentials must not look real:**
   - Use mock values like `TestPass${RANDOM}` in tests
   - Use placeholder values that clearly indicate testing
   - Generate unique values per test run when possible

5. **Pre-commit hooks will check for secrets:**
   - Ensure all hooks pass before pushing
   - Use `gitleaks` to scan for accidentally committed secrets
   - Fix any detection issues before submitting PR

## Getting Started

### Setup

1. Fork the repository
2. Clone your fork using SSH:
   ```bash
   git clone git@github.com:your-username/openwrt-extended-backup.git
   cd openwrt-extended-backup
   ```

3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature
   ```

4. Install development dependencies:
   ```bash
   # Install pre-commit hooks
   pre-commit install
   ```

### Making Changes

1. **Write code following existing patterns** - Review similar code for style/conventions
2. **Test your changes** - Run tests to ensure nothing breaks:
   ```bash
   make test
   ```

3. **Lint your shell scripts** - Ensure code quality:
   ```bash
   make shellcheck
   ```

4. **Never commit secrets** - Review your diff carefully:
   ```bash
   git diff
   git diff --staged
   ```

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run specific test file
bats tests/openwrt_full_backup.bats

# Run specific test
bats tests/openwrt_full_backup.bats -f "test name pattern"
```

### Writing Tests

- Use descriptive test names
- Use generated/mock credentials (never hardcoded)
- Clean up test artifacts
- Follow the existing test structure

Example:
```bash
@test "test description" {
  # Generate unique test credentials
  local test_password="TestPass${RANDOM}"
  export TEST_VAR="${test_password}"
  
  # Your test code
  
  # Cleanup
  unset TEST_VAR
}
```

## Code Style

### Shell Scripts

- Use POSIX sh where possible
- Follow existing formatting and naming conventions
- Use meaningful variable names
- Add comments for complex logic
- Run shellcheck for validation

### General Guidelines

- One feature per pull request
- Write clear commit messages
- Squash related commits before submitting PR
- Update README if adding features
- Update CHANGELOG.md with your changes

## Submitting Changes

### Before You Submit

1. ✅ Run tests: `make test`
2. ✅ Run shellcheck: `make shellcheck`
3. ✅ Review your diff - ensure no secrets
4. ✅ Pre-commit hooks pass
5. ✅ Update CHANGELOG.md and README if needed

### Creating a Pull Request

1. Push your feature branch
2. Create a Pull Request with:
   - Clear description of changes
   - Reference to any related issues
   - Test coverage information
   - Screenshots for UI changes (if applicable)

3. Respond to code review feedback promptly

## Reporting Issues

- **Security issues**: See [SECURITY.md](./SECURITY.md)
- **Bug reports**: Provide reproducible steps and context
- **Feature requests**: Describe the use case and expected behavior

## Questions?

- Check existing issues and discussions
- Read the README and documentation
- Ask maintainers if unclear

## Attribution

Contributors will be credited in CHANGELOG.md and project documentation.

Thank you for helping make this project better! 🎉
