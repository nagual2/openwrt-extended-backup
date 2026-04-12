# Набор утилит расширенного резервного копирования OpenWrt

[English](README.md) | **Русский** | [Deutsch](README.de.md)  
*[Contributing](docs/CONTRIBUTING.md) | [Участие](docs/CONTRIBUTING.ru.md) | [Mitwirken](docs/CONTRIBUTING.de.md) · [Security Audit](docs/SECURITY_AUDIT_FIXES.md) | [Аудит](docs/SECURITY_AUDIT_FIXES.ru.md) | [Audit](docs/SECURITY_AUDIT_FIXES.de.md)*

[![CI](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/ci.yml)

Коллекция POSIX shell-утилит, работающих непосредственно на роутерах OpenWrt. Инструменты помогают экспортировать записываемый overlay, безопасно восстановить сохранённый архив и записать список пакетов, установленных вручную.

> Вывод CLI в настоящее время на русском языке. Поведение и опции документированы на английском ниже до обновления локализации.

## Что включено

| Команда | Назначение |
| --- | --- |
| `openwrt_full_backup` | Создаёт tar.gz-архив `/overlay`, выводит команду scp и может открыть доступ к результату через временную SMB-шару через `ksmbd`. |
| `openwrt_restore` | Проверяет архив резервной копии, распаковывает его в целевой overlay, сохраняет снапшоты текущего состояния и при необходимости перезапускает сохранённые скрипты установки пакетов. |
| `user_installed_packages` | Создаёт детерминированный скрипт переустановки для пакетов, установленных вручную через `opkg`, с опциональными фильтрами и внешними списками пакетов. |

Все скрипты находятся в [`scripts/`](./scripts/) и используют общие вспомогательные функции из [`scripts/lib`](./scripts/lib). Тонкие лаунчеры сохраняют доступность legacy-имён команд после рефакторинга.

## Требования

- OpenWrt 22.03 или новее с BusyBox ≥ 1.35.
- `tar`, `coreutils-sha256sum` и стандартные базовые утилиты OpenWrt.
- Опционально: `ksmbd-tools` для открытия SMB-шар из скрипта резервного копирования.
- Root-доступ при восстановлении архивов или записи в `/overlay`.

## Установка

### Скачать из релиза

1. Загрузите последний `.tar.gz` или `.zip` из [GitHub Releases](https://github.com/nagual2/openwrt-extended-backup/releases).
2. Распакуйте архив — он содержит только директорию `scripts/` плюс документацию.
3. Скопируйте нужные скрипты на роутер (например, через `scp`) и сделайте их исполняемыми через `chmod +x`.

### Сборка и установка `.ipk`

```
make ipk            # собирает dist/ctoolkit_<version>-1_all.ipk
make install        # устанавливает собранный пакет через opkg, если доступен
```

Установите `WITH_KSMBD=0`, если не хотите зависимость пакета от `ksmbd-tools`.

### Ручная установка

```
scp scripts/openwrt_full_backup root@<router>:/usr/sbin/
scp scripts/openwrt_restore root@<router>:/usr/sbin/
scp scripts/user_installed_packages root@<router>:/usr/bin/
chmod +x /usr/sbin/openwrt_full_backup /usr/sbin/openwrt_restore /usr/bin/user_installed_packages
```

## Использование

### `openwrt_full_backup`

```
openwrt_full_backup [--output ПУТЬ] [--overlay ДИРЕКТОРИЯ] [--export=smb] [--dry-run]
```

- `--output ПУТЬ` — директория, куда будет записан tar.gz-архив (по умолчанию `/tmp`).
- `--overlay ДИРЕКТОРИЯ` — источник overlay (по умолчанию `/overlay`).
- `--export=smb` — открыть доступ к созданному архиву через временную шару `ksmbd`.
- `--dry-run` — проверить требования и показать действия без создания архива.
- `-V/--version`, `-h/--help` — вывести версию или справку.

Команда выводит абсолютный путь к созданному архиву и команду `scp`, которую можно выполнить с рабочей станции. При включённом SMB-экспорте также выводятся учётные данные и путь к шаре.

### `openwrt_restore`

```
openwrt_restore [--archive ПУТЬ] [--packages ПУТЬ] [--dry-run] [--no-reboot]
                 [--overlay ДИРЕКТОРИЯ] [--force]
```

- `--archive ПУТЬ` — расположение архива резервной копии для восстановления. Запрашивает интерактивно, если не указан.
- `--packages ПУТЬ` — скрипт с командами `opkg` для переустановки пакетов после восстановления overlay.
- `--dry-run` — проверить архив, создать отчёт и остановиться без модификации системы.
- `--no-reboot` — пропустить автоматическую перезагрузку после завершения восстановления.
- `--overlay ДИРЕКТОРИЯ` — переопределить точку монтирования overlay (полезно для тестов или recovery-образов).
- `--force` — обойти проверки окружения, которые обычно защищают от запуска вне OpenWrt.
- `-V/--version`, `-h/--help` — вывести версию или справку.

Процесс восстановления проверяет tarball, опционально проверяет SHA-256 суммы, распаковывает архив во временное рабочее пространство, делает снапшот текущего overlay, копирует файлы с сохранением владельцев и прав и перезапускает ключевые сервисы. Если аргумент `--packages` не указан, используется `user_installed_packages` для автоматической генерации скрипта переустановки.

### `user_installed_packages`

```
user_installed_packages [--status-file ПУТЬ] [--user-installed-file ПУТЬ]
                        [--include-auto-deps[=BOOL]] [--output ПУТЬ]
                        [-x ШАБЛОН]
```

- `--status-file ПУТЬ` — альтернативный файл статуса `opkg` (по умолчанию `/usr/lib/opkg/status`).
- `--user-installed-file ПУТЬ` — добавить названия пакетов из внешнего списка.
- `-x/--exclude ШАБЛОН` — исключить пакеты, соответствующие shell-glob (можно повторять).
- `--include-auto-deps[=BOOL]` — включить записи с пометкой `Auto-Installed: yes`.
- `--output ПУТЬ` — записать вывод в файл (`-` оставляет stdout).
- `-V/--version`, `-h/--help` — вывести версию или справку.

Скрипт выводит сгруппированные, отсортированные названия пакетов, за которыми следуют готовые к выполнению команды `opkg install`. Если файл статуса отсутствует, используется `opkg list-installed` для работы на минимальных системах.

## Разработка

```
make fmt    # форматирование shell-скриптов через shfmt -w
make lint   # запуск ShellCheck для всех исполняемых shell-скриптов
make test   # выполнение тестового набора Bats
make all    # сокращение для "make lint test"
```

Релизная упаковка (`make ipk`) устанавливает `openwrt_full_backup`, `openwrt_restore`, лаунчер совместимости `openwrt_full_restore` и `user_installed_packages` вместе с документацией. GitHub Releases публикуют тот же набор runtime-файлов без development-хелперов или тестов.

## Лицензия

Этот проект распространяется на условиях [MIT License](./LICENSE).
