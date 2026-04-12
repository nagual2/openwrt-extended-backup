# Встроенные shell-инструменты

[English](README.md) | **Русский** | [Deutsch](README.de.md)

Эта директория предоставляет предварительно собранные исполняемые файлы, которые управляют CI задачей `shell quality` репозитория. Артефакты встроены (vendored), чтобы CI мог работать без сетевых загрузок.

## Инвентарь инструментов

### shfmt
- Версия: [v3.12.0](https://github.com/mvdan/sh/releases/tag/v3.12.0) (linux-amd64 релиз-ассет `shfmt_v3.12.0_linux_amd64`)
- Лицензия: [BSD 3-Clause](LICENSES/shfmt)
- Точка входа: `tools/shfmt`

### ShellCheck
- Версия: [v0.11.0](https://github.com/koalaman/shellcheck/releases/tag/v0.11.0) (linux x86_64 статическая сборка)
- Лицензия: [GNU GPL v3](LICENSES/shellcheck)
- Точка входа: `tools/shellcheck`

### bats-core
- Версия: [v1.12.0](https://github.com/bats-core/bats-core/releases/tag/v1.12.0)
- Лицензия: [MIT](bats-core/LICENSE.md)
- Точка входа: `tools/bats-core/bin/bats`

## Локальная разработка

По умолчанию Makefile-таргеты используют эти встроенные инструменты. Разработчики, предпочитающие системно установленные утилиты, могут включить опцию через установку `USE_SYSTEM_TOOLS=1`, например:

```
USE_SYSTEM_TOOLS=1 make lint
```

При обновлении до новых версий любого инструмента загрузите релиз-артефакты для linux-amd64, замените файлы в этой директории и обновите ссылки на версии в этом документе и в CI workflow соответственно.
