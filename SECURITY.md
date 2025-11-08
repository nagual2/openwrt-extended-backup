# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please **do not** open a public issue. Instead, please report it responsibly by:

1. **Email**: Send a detailed report to the project maintainers with:
   - Description of the vulnerability
   - Steps to reproduce (if applicable)
   - Potential impact
   - Suggested fix (if you have one)

2. **Timeline**: We will:
   - Acknowledge receipt within 48 hours
   - Provide an estimated timeline for a fix
   - Request confirmation before public disclosure
   - Credit you in the fix announcement (unless you prefer anonymity)

## Security Guidelines

### For Contributors

- **Never commit credentials**: API keys, tokens, passwords, SSH keys, or other secrets must never be committed to version control
- **Use environment variables**: Store sensitive data in environment variables or configuration files that are gitignored
- **Review before committing**: Use `git diff` to review changes before committing
- **Pre-commit hooks**: This project uses pre-commit hooks to detect secrets - ensure they pass before pushing

### For Users

- **SSH Authentication**: Use SSH keys for git operations instead of HTTPS with embedded credentials
- **Access Control**: Protect your SSH keys and credentials appropriately
- **Updates**: Keep your OpenWrt system and this toolkit updated for security patches

## Security Scanning

This project uses automated tools to detect potential security issues:

- **gitleaks**: Scans for accidentally committed secrets and credentials
- **shellcheck**: Validates shell script security practices
- **git hooks**: Pre-commit hooks prevent secrets from being committed

## Best Practices

### Git Configuration

Configure git to use SSH instead of HTTPS:

```bash
# Instead of HTTPS with embedded tokens
# git clone https://user:token@github.com/repo.git

# Use SSH (requires SSH key setup)
git clone git@github.com:repo.git
```

### Environment Variables

For local development, create a `.env` file (never commit this):

```bash
# .env (add to .gitignore)
TEST_PASSWORD=your_test_password
KSMBD_PASSWORD=your_test_password
```

### Test Credentials

Test files should never contain hardcoded credentials. Instead:

1. Use generated test values with timestamps/randomization
2. Use environment variables from `.env.example`
3. Use mock/placeholder values that clearly indicate they're for testing

## Compliance

This project aims to comply with:

- OWASP Guidelines for secure coding
- CWE (Common Weakness Enumeration) best practices
- Common secure shell scripting standards

## Questions or Concerns?

If you have questions about security practices or policies, please open a discussion or contact the maintainers.
