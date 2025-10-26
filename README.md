# openwrt_full_backup & openwrt_full_restore

<<<<<<< HEAD
[![Shell quality checks](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/shell-quality.yml/badge.svg?branch=main)](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/shell-quality.yml)
=======
[![CI](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/ci.yml)
>>>>>>> origin/merge-tasks-1-15-into-main-e01

Набор shell-утилит, выполняющихся напрямую на маршрутизаторе под управлением OpenWrt. Основной сценарий `openwrt_full_backup` создаёт полную резервную копию пользовательского слоя (`/overlay`), сохраняет архив в выбранный каталог (по умолчанию `/tmp`) и выводит готовую команду `scp` для копирования. При необходимости скрипт умеет поднять временную SMB-шару через `ksmbd`. Комплементарная утилита `openwrt_restore` валидирует архив, при наличии проверяет контрольную сумму, создаёт резервный снимок текущего `/overlay`, безопасно применяет резервную копию, поддерживает dry-run, переустановку пакетов и опциональный reboot. Наследуемый сценарий `openwrt_full_restore` остаётся для совместимости. Вспомогательный скрипт `user_installed_packages` выводит список вручную установленных пакетов для последующей переустановки.

Для политики ветвления и требований к PR см. [CONTRIBUTING.md](./CONTRIBUTING.md).

## Минимальный процесс контрибуции

1. Создайте ветку от `main` с осмысленным именем (см. рекомендации в `CONTRIBUTING.md`).
2. Выполните локальные проверки качества: `./scripts/ci/check-shell-quality.sh`.
3. Откройте Pull Request в `main` и убедитесь, что CI зелёный:
   - **Shell quality checks / Shell quality**;
   - **Post-release verify / Verify release metadata**.
4. Дождитесь аппрува мейнтейнеров (для изменений в `scripts/` и `.github/workflows/` они назначаются через `CODEOWNERS`) и нажмите Merge только после успешных проверок. Форс-пуш в `main` запрещён.

> ⚠️ Архив сохраняется в оперативной памяти (по умолчанию в `/tmp`). После перезагрузки маршрутизатора файл исчезает — скачайте и сохраните его сразу после создания.

## Назначение
- Создание автономной резервной копии конфигурации и пользовательских данных OpenWrt.
- Безопасное восстановление архива на идентичную прошивку с проверкой и резервированием текущих файлов.
- Получение списка вручную установленных `opkg`-пакетов для повторной установки.

## Основные возможности
- `openwrt_full_backup`
  - Архивирует весь пользовательский слой (`/overlay`) с сохранением прав и владельцев.
  - По умолчанию выводит команду `scp` для скачивания архива и поддерживает `--emit-scp-cmd` для интеграции в автоматизацию.
  - Управляется через флаг `--export` (`scp`, `local`, `smb`), а также предоставляет флаги `--ssh-host`, `--ssh-port`, `--ssh-user`, `--out-dir`, `--emit-scp-cmd`, `-q` и `-v` для настройки поведения.
  - При `--export=smb` настраивает временную SMB-шару (при наличии `ksmbd`) без автоматической установки пакетов.
- `openwrt_restore`
  - Проверяет архив (`tar -tzf`) и при наличии файла `*.sha256`/`*.sha256sum` сверяет контрольную сумму.
  - Перед применением создаёт архив-снимок текущего `/overlay` в `TMPDIR`, умеет работать в режиме dry-run без изменений.
  - Приостанавливает вспомогательные службы, аккуратно распаковывает резервную копию в указанный overlay (поддерживает `--overlay` для тестов) и выполняет `sync`.
  - Переустанавливает пакеты из переданного скрипта или генерирует команды через `user_installed_packages`, при необходимости пропускает шаг.
  - По завершении может инициировать перезагрузку (отключается `--no-reboot`).
- `openwrt_full_restore`
  - Сохранён для обратной совместимости: формирует подробный отчёт, создаёт резервные копии перезаписываемых файлов и предлагает перезапуск служб.
- `user_installed_packages`
  - Генерирует детерминированный список и команды для переустановки вручную установленных `opkg`-пакетов с опциями фильтрации.

## Требования
- Маршрутизатор под управлением OpenWrt ≥ 22.03 с BusyBox ≥ 1.35.0.
- Доступ по SSH (root) или через локальную консоль.
- Свободная оперативная память для хранения архива (как минимум объём, сопоставимый с используемым `/overlay`).
- Доступ в интернет для установки отсутствующих пакетов (опционально, при первом запуске).
- (Опционально) Пакет `ksmbd-server`, если планируется использование `--export=smb`.

## Установка

### Через пакет .ipk
1. Соберите пакет самостоятельно (см. раздел «Сборка пакета (.ipk)») или скачайте готовый файл `ctoolkit_*.ipk`.
2. Передайте его на роутер, например:
   ```sh
   scp dist/ctoolkit_*.ipk root@<ip_роутера>:/tmp/
   ```
3. Установите пакет:
   ```sh
   opkg install /tmp/ctoolkit_*.ipk
   ```

Готовые сборки автоматически публикуются в разделе [GitHub Releases](https://github.com/nagual2/openwrt-extended-backup/releases) вместе с feed-индексом (`Packages.gz`) и файлами контрольных сумм.

Скрипты устанавливаются в `/usr/bin/` и становятся доступны по именам `openwrt_full_backup`, `openwrt_full_restore` и `user_installed_packages`. По умолчанию вместе с пакетом будет установлена зависимость `ksmbd-tools`; чтобы исключить её, соберите пакет с параметром `WITH_KSMBD=0`.

### Ручная установка скриптов
```sh
# Основной скрипт резервного копирования
wget https://raw.githubusercontent.com/nagual2/openwrt-extended-backup/main/scripts/openwrt_full_backup -O /backup
chmod +x /backup

# Современный скрипт восстановления
wget https://raw.githubusercontent.com/nagual2/openwrt-extended-backup/main/scripts/openwrt_restore -O /restore
chmod +x /restore

# Легаси-вариант (по желанию)
wget https://raw.githubusercontent.com/nagual2/openwrt-extended-backup/main/scripts/openwrt_full_restore -O /restore_legacy
chmod +x /restore_legacy

# Вспомогательный список пользовательских пакетов
wget https://raw.githubusercontent.com/nagual2/openwrt-extended-backup/main/scripts/user_installed_packages -O /usr/bin/user_installed_packages
chmod +x /usr/bin/user_installed_packages
```

При ручной установке скрипты `/backup` и `/restore` можно запускать напрямую — они хранятся в постоянной памяти и остаются доступными после перезагрузки.

## Сборка пакета (.ipk)

### Через OpenWrt buildroot/SDK
1. Подключите репозиторий как feed (например, добавьте строку `src-git ctoolkit https://github.com/nagual2/openwrt-extended-backup.git` в `feeds.conf`) или скопируйте каталог `package/ctoolkit/` из этого репозитория в `package/ctoolkit` внутри сборочной среды.
2. Если используете feeds, обновите и установите пакет:
   ```sh
   ./scripts/feeds update ctoolkit
   ./scripts/feeds install ctoolkit
   ```
   При ручном копировании каталога этот шаг можно пропустить.
3. При необходимости отключите зависимость `ksmbd-tools` через `make menuconfig` (Utilities → ctoolkit).
4. Соберите пакет:
   ```sh
   make package/ctoolkit/compile V=sc
   ```

Готовый `ipk` окажется в каталоге `bin/packages/<архитектура>/packages/`.

### Локальная сборка без SDK

В корне проекта доступен упрощённый `Makefile`:

```sh
make ipk              # соберёт dist/ctoolkit_<версия>-1_all.ipk
make ipk WITH_KSMBD=0 # исключить зависимость на ksmbd-tools
make install          # установит пакет через opkg, если утилита доступна на хосте
```

Достаточно стандартных утилит `tar` и `ar`. Готовые файлы появляются в каталоге `dist/`.

## Быстрый старт
1. Подключитесь к роутеру по SSH и запустите `openwrt_full_backup` (или `/backup`, если используете ручную установку).
2. После завершения скрипт сообщит путь к архиву и выведет готовую команду `scp`. По умолчанию архив создаётся в `/tmp`.
3. На локальной машине выполните показанную команду `scp`, при необходимости добавив свой ключ и проверку хоста. Пример:
   ```sh
   scp -i ~/.ssh/openwrt_ed25519 -o StrictHostKeyChecking=accept-new root@192.168.1.1:/tmp/fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz ./
   ```
4. После скачивания удалите архив на роутере, чтобы освободить оперативную память: `rm -f /tmp/fullbackup_*`.
5. (Опционально) Для сетевого доступа по SMB запустите `openwrt_full_backup --export=smb` на устройстве с установленным `ksmbd`.
6. (Опционально) Выполните `user_installed_packages` для генерации списка вручную установленных пакетов.
7. Для восстановления воспользуйтесь `openwrt_restore --archive /tmp/fullbackup_*.tar.gz` (есть режим dry-run, проверка sha256, переустановка пакетов и опциональный reboot). При необходимости доступен совместимый `openwrt_full_restore`.

## Опции CLI
| Скрипт | Опции | Поведение |
| --- | --- | --- |
| `openwrt_full_backup` | `-h`, `--help`, `-V`, `--version`, `--export`, `--out-dir`, `--ssh-host`, `--ssh-port`, `--ssh-user`, `--emit-scp-cmd`, `-v`, `-q` | Создаёт архив `/overlay`, по умолчанию сохраняет его в `/tmp` и выводит команду `scp`. При `--export=smb` настраивает временную SMB-шару (при наличии `ksmbd`). |
| `openwrt_restore` | `--archive`, `--packages`, `--dry-run`, `--overlay`, `--no-reboot`, `--force`, `-h`, `--help`, `-V`, `--version` | Проверяет архив (включая sha256 при наличии), делает снимок текущего `overlay`, безопасно применяет резервную копию, переустанавливает пакеты и позволяет отключить автоматическую перезагрузку. |
| `openwrt_full_restore` | `-h`, `--help`, `-V`, `--version`, `-a`, `--archive`, `-d`, `--dry-run`, `-p`, `--packages`, `--no-packages`, `-y`, `--yes` | Легаси-скрипт с интерактивным отчётом, резервированием перезаписываемых файлов и подсказками по перезапуску служб. |
| `user_installed_packages` | `-h`, `--help`, `-V`, `--version`, `--status-file`, `--user-installed-file`, `-x`, `--exclude`, `--include-auto-deps` | Анализирует текущую систему и выводит отсортированные команды `opkg`. |

<<<<<<< HEAD
## Версионирование и релизы
- Текущая версия хранится в файле `VERSION` в корне репозитория.
- Оба скрипта поддерживают флаги `-V`/`--version` для быстрого вывода версии без запуска основной логики.
- Workflow [`Release`](.github/workflows/release.yml) использует [release-please](https://github.com/googleapis/release-please) для формирования GitHub Releases, обновления `CHANGELOG.md` и автоматической публикации архивов со скриптами.
=======
Run the backup script as root on the router. By default, it stores the archive in `/tmp`, prints the full path, and shows an `scp` command that you can run from your workstation.
>>>>>>> origin/merge-tasks-1-15-into-main-e01

## Примеры
### SCP по умолчанию
```sh
openwrt_full_backup
# Скрипт напечатает команду вида:
# scp root@OpenWrt:/tmp/fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz <destination>
# На локальной машине выполните команду, при необходимости добавив ключ и параметры проверки:
scp -i ~/.ssh/openwrt_ed25519 \
    -o StrictHostKeyChecking=accept-new \
    root@OpenWrt:/tmp/fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz \
    ~/Backups/
```
Для автоматизации можно использовать `--emit-scp-cmd`, чтобы вывести только команду без дополнительных сообщений:
```sh
openwrt_full_backup --emit-scp-cmd --ssh-host 192.168.1.1 --ssh-user root --ssh-port 2222 > /tmp/scp-command.txt
sh /tmp/scp-command.txt
```

### SMB / ksmbd
```sh
openwrt_full_backup --export=smb --out-dir /tmp/archive
smbclient //192.168.1.1/owrt_archive -U owrt_backup%<пароль> -c 'ls'
# Замените имя файла на актуальное
smbclient //192.168.1.1/owrt_archive -U owrt_backup%<пароль> -c 'get fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz'
```
После копирования отключите шару (через LuCI или `/etc/init.d/ksmbd stop`) и удалите архив:
```sh
rm -f /tmp/archive/fullbackup_*
```

### Восстановление и dry-run
```sh
# Проверяем архив без внесения изменений
openwrt_restore --dry-run --archive /tmp/fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz --no-reboot

# Применяем восстановление с переустановкой пакетов без автоперезагрузки
openwrt_restore --archive /tmp/fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz --packages /tmp/opkg-user-packages.sh --no-reboot
```
После применения изучите журнал: утилита сообщит путь к снимку текущего `/overlay`, статус скрипта пакетов и напомнит вручную перезагрузить устройство при необходимости.

### Список пользовательских пакетов
```sh
user_installed_packages > /tmp/opkg-user-packages.sh
scp root@192.168.1.1:/tmp/opkg-user-packages.sh ./
```
Скрипт анализирует `/usr/lib/opkg/status`, исключает базовые пакеты с минимальным временем установки прошивки и зависимости, помеченные `Auto-Installed: yes`, а при наличии дополняет результат данными из списка `user-installed`. На выходе получается детерминированный список и готовые команды для переустановки:

```text
# user-installed opkg packages (7)
# main packages (6)
bash
htop
luci-app-sqm
luci-theme-material
smartmontools
tailscale
<<<<<<< HEAD

=======
htop
>>>>>>> origin/merge-tasks-1-15-into-main-e01
# LuCI translations (1)
luci-i18n-firewall-ru
opkg update
opkg install bash htop luci-app-sqm luci-theme-material smartmontools tailscale
opkg install luci-i18n-firewall-ru
```

Можно, например, скрыть локализации (`user_installed_packages --exclude 'luci-i18n-*'`) или вернуть зависимости, помеченные `Auto-Installed: yes` (`user_installed_packages --include-auto-deps`).

## Меры безопасности
- Используйте SMB-шару только в доверенной сети. После копирования архива остановите `ksmbd` и удалите созданного пользователя: `ksmbd.deluser owrt_backup`.
- Смените пароль для SMB-шары вручную, если планируете использовать её повторно.
- Не храните архив на самом роутере дольше, чем необходимо.
- Поскольку архив содержит все настройки и пароли, держите его в зашифрованном или защищённом хранилище.
- Обновляйте OpenWrt и пакеты безопасности до актуальных версий перед созданием резервных копий.

## Ограничения и что не бэкапится
- Архив сохраняется в оперативной памяти (`/tmp`) и исчезает после перезагрузки.
- Резервная копия рассчитана на восстановление **на ту же версию прошивки**. Межверсийное восстановление не гарантируется.
- Не архивируются временные рабочие каталоги (`/overlay/work`, `run`) и системные файлы `os-release`, исключённые намеренно.
- В архив не попадают данные с внешних накопителей (`/mnt`, `/dev/sdX`) — их нужно копировать отдельно.
- Скрипт не выполняет шифрование и проверку целостности архива — рекомендуется проверять `tar -tzf` вручную.
- Для работы требуется установленная утилита `tar`; при отсутствии интернет-доступа её автоустановка будет невозможна.

## Проверенные версии OpenWrt и BusyBox
| OpenWrt | BusyBox | Примечание |
| --- | --- | --- |
| 23.05.3 | 1.36.1 | Ручная проверка на x86-64 и MT7621. |
| 22.03.5 | 1.35.0 | Проверено на MT7620A/ramips. |

Если у вас получилось успешно использовать скрипты на других версиях — дайте знать через Issue или Pull Request.

## Руководства
- [Подробное восстановление из резервной копии](docs/restore-guide.md)

---

<<<<<<< HEAD
Скрипты распространяются «как есть». Будем рады обратной связи и улучшениям через Pull Request.
=======
The CI workflow defined in `ci.yml` runs the same formatting and test checks.

## Releases

- The current version is stored in the root `VERSION` file.
- Both scripts expose `-V`/`--version` to print the version without executing the main logic.
- The workflow [`.github/workflows/release.yml`](.github/workflows/release.yml) runs on tags matching `v*`, builds `openwrt-extended-backup-${VERSION}.tar.gz` and `.zip`, generates `SHA256SUMS`, and publishes a GitHub Release using the matching section from `CHANGELOG.md`.
- To publish a new release manually (example for `v0.1.0`):
  1. Update `VERSION`: `printf '0.1.0\n' > VERSION`.
  2. Add or update the `## [v0.1.0]` section in `CHANGELOG.md` with the release notes.
  3. Commit the changes: `git commit -am "chore: prepare release 0.1.0"`.
  4. Create an annotated tag: `git tag -a v0.1.0 -m "v0.1.0"`.
  5. Push the branch and tag: `git push origin main && git push origin v0.1.0`.
  6. Wait for GitHub Actions to publish the release with packaged archives and `SHA256SUMS`.
>>>>>>> origin/merge-tasks-1-15-into-main-e01
