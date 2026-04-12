# Eingebettete Shell-Tools

[English](README.md) | [Русский](README.ru.md) | **Deutsch**

Dieses Verzeichnis bietet die vorgefertigten ausführbaren Dateien, die den `shell quality`-Continuous-Integration-Job des Repositorys antreiben. Die Artefakte sind eingebettet (vendored), damit CI ohne Netzwerk-Downloads ausgeführt werden kann.

## Tool-Inventar

### shfmt
- Version: [v3.12.0](https://github.com/mvdan/sh/releases/tag/v3.12.0) (linux-amd64 Release-Asset `shfmt_v3.12.0_linux_amd64`)
- Lizenz: [BSD 3-Clause](LICENSES/shfmt)
- Einstiegspunkt: `tools/shfmt`

### ShellCheck
- Version: [v0.11.0](https://github.com/koalaman/shellcheck/releases/tag/v0.11.0) (linux x86_64 statischer Build)
- Lizenz: [GNU GPL v3](LICENSES/shellcheck)
- Einstiegspunkt: `tools/shellcheck`

### bats-core
- Version: [v1.12.0](https://github.com/bats-core/bats-core/releases/tag/v1.12.0)
- Lizenz: [MIT](bats-core/LICENSE.md)
- Einstiegspunkt: `tools/bats-core/bin/bats`

## Lokale Entwicklung

Standardmäßig verwenden die Makefile-Targets diese eingebetteten Tools. Entwickler, die systeminstallierte Dienstprogramme bevorzugen, können sich durch Setzen von `USE_SYSTEM_TOOLS=1` anmelden, zum Beispiel:

```
USE_SYSTEM_TOOLS=1 make lint
```

Beim Update auf neuere Versionen eines Tools laden Sie die Release-Artefakte für linux-amd64 herunter, ersetzen Sie die Dateien in diesem Verzeichnis und aktualisieren Sie die Versionsreferenzen in diesem Dokument und im CI-Workflow entsprechend.
