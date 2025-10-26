# openwrt_full_backup & openwrt_full_restore

[![Shell quality checks](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/shell-quality.yml/badge.svg?branch=main)](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/shell-quality.yml)

Набор shell-утилит, выполняющихся напрямую на маршрутизаторе под управлением OpenWrt. Основной сценарий `openwrt_full_backup` создаёт полную резервную копию пользовательского слоя (`/overlay`), сохраняет архив в выбранный каталог (по умолчанию `/tmp`) и выводит готовую команду `scp` для копирования. При необходимости скрипт умеет поднять временную SMB-шару через `ksmbd`. Комплементарная утилита `openwrt_full_restore` валидирует архив, безопасно восстанавливает файлы с предварительным резервным копированием текущего состояния, поддерживает dry-run и переустановку пакетов. Вспомогательный скрипт `user_installed_packages` выводит список вручную установленных пакетов для последующей переустановки.

Для политики ветвления и требований к PR см. [CONTRIBUTING.md](./CONTRIBUTING.md).

> ⚠️ Архив сохраняется в оперативной памяти (по умолчанию в `/tmp`). После перезагрузки маршрутизатора файл исчезает — скачайте и сохраните его сразу после создания.

## Назначение
- Создание автономной резервной копии конфигурации и пользовательских данных OpenWrt.
- Безопасное восстановление архива на идентичную прошивку с проверкой и резервированием текущих файлов.
- Получение списка вручную установленных `opkg`-пакетов для повторной установки.

## Основные возможности
- `openwrt_full_backup`
  - Архивирует весь пользовательский слой (`/overlay`) с сохранением прав и владельцев.
  - По умолчанию выполняет удалённую выгрузку через SCP: после создания архива печатает готовую команду `scp`, поддерживает `--emit-scp-cmd` для автоматизации и опции `--ssh-host`, `--ssh-port`, `--ssh-user` для корректного доступа к роутеру из внешней сети.
  - Режим экспорта настраивается через `--export` (`scp`, `local`, `smb`), можно указать каталог назначения `--out-dir` и управлять уровнем логирования (`-q`, `-v`).
  - При `--export=smb` настраивает временную SMB-шару (при наличии `ksmbd`) без автоматической установки пакетов.
- `openwrt_full_restore`
  - Валидирует архив (`tar -tzf`) и умеет работать в режиме dry-run без изменений на роутере.
  - Перед распаковкой создаёт резервные копии перезаписываемых файлов в `/tmp/openwrt-restore-backup-*`.
  - Распаковывает с сохранением атрибутов, восстанавливает права и владельцев, отслеживает новые и изменённые файлы.
  - Предлагает запустить сохранённый список пакетов и перезапускает ключевые службы (network, wifi, firewall, dnsmasq, dropbear, sqm) при необходимости.
  - Формирует итоговый отчёт со списком действий и путём до резервных копий.
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
1. Соберите пакет самостоятельно (см. раздел «Сборка пакета (.ipk)») или скачайте готовый артефакт `openwrt-extended-backup_*.ipk` из релиза GitHub.
2. Передайте его на роутер, например:
   ```sh
   scp dist/openwrt-extended-backup_*.ipk root@<ip_роутера>:/tmp/
   ```
3. Установите пакет:
   ```sh
   opkg install /tmp/openwrt-extended-backup_*.ipk
   ```

Скрипты устанавливаются в `/usr/sbin/` и становятся доступны по именам `openwrt_full_backup`, `openwrt_full_restore` и `user_installed_packages`. По умолчанию вместе с пакетом будет установлена зависимость `ksmbd-tools`; чтобы исключить её, соберите пакет с параметром `WITH_KSMBD=0`.

### Ручная установка скриптов
```sh
# Основной скрипт резервного копирования
wget https://raw.githubusercontent.com/nagual2/openwrt-extended-backup/main/scripts/openwrt_full_backup -O /backup
chmod +x /backup

# Скрипт восстановления (необязательно, но рекомендуется)
wget https://raw.githubusercontent.com/nagual2/openwrt-extended-backup/main/scripts/openwrt_full_restore -O /restore
chmod +x /restore

# Вспомогательный список пользовательских пакетов
wget https://raw.githubusercontent.com/nagual2/openwrt-extended-backup/main/scripts/user_installed_packages -O /usr/bin/user_installed_packages
chmod +x /usr/bin/user_installed_packages
```

При ручной установке скрипты `/backup` и `/restore` можно запускать напрямую — они хранятся в постоянной памяти и остаются доступными после перезагрузки.

## Сборка пакета (.ipk)

### Через OpenWrt buildroot/SDK
1. Подключите репозиторий как feed (например, добавьте строку `src-git extended_backup https://github.com/nagual2/openwrt-extended-backup.git` в `feeds.conf`) или скопируйте каталог `openwrt/` из этого репозитория в `package/openwrt-extended-backup` внутри сборочной среды.
2. Если используете feeds, обновите и установите пакет:
   ```sh
   ./scripts/feeds update extended_backup
   ./scripts/feeds install openwrt-extended-backup
   ```
   При ручном копировании каталога этот шаг можно пропустить.
3. При необходимости отключите зависимость `ksmbd-tools` через `make menuconfig` (Utilities → openwrt-extended-backup).
4. Соберите пакет:
   ```sh
   make package/openwrt-extended-backup/compile V=sc
   ```

Готовый `ipk` окажется в каталоге `bin/packages/<архитектура>/packages/`.

### Локальная сборка без SDK

В корне проекта доступен упрощённый `Makefile`:

```sh
make ipk              # соберёт dist/openwrt-extended-backup_<версия>-1_all.ipk
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
7. Для восстановления воспользуйтесь `openwrt_full_restore --archive /tmp/fullbackup_*.tar.gz` (доступен режим dry-run и автоматическая переустановка пакетов).

## Опции CLI
| Скрипт | Опции | Поведение |
| --- | --- | --- |
| `openwrt_full_backup` | `-h`, `--help`, `-V`, `--version`, `--export`, `--out-dir`, `--ssh-host`, `--ssh-port`, `--ssh-user`, `--emit-scp-cmd`, `-v`, `-q` | Создаёт архив `/overlay`, по умолчанию сохраняет его в `/tmp` и выводит команду `scp`. При `--export=smb` настраивает временную SMB-шару (при наличии `ksmbd`). |
| `openwrt_full_restore` | `-h`, `--help` | Выводит краткую справку по доступным опциям. |
| `openwrt_full_restore` | `-V`, `--version` | Показывает версию и завершает выполнение. |
| `openwrt_full_restore` | `-a`, `--archive PATH` | Использует указанный архив; без параметра запросит путь интерактивно. |
| `openwrt_full_restore` | `-d`, `--dry-run` | Выполняет проверку архива и формирует отчёт без изменений в системе. |
| `openwrt_full_restore` | `-p`, `--packages PATH` | После распаковки запускает скрипт переустановки пакетов по указанному пути. |
| `openwrt_full_restore` | `--no-packages` | Пропускает шаг с переустановкой пакетов и не задаёт вопрос. |
| `openwrt_full_restore` | `-y`, `--yes` | Автоматически подтверждает действия (без дополнительных вопросов). |
| `user_installed_packages` | `-h`, `--help` | Выводит краткую справку и перечисление доступных опций. |
| `user_installed_packages` | `-V`, `--version` | Выводит текущую версию утилиты и завершает выполнение. |
| `user_installed_packages` | `--status-file PATH` | Использует альтернативный `opkg` статус-файл (например, для тестов). |
| `user_installed_packages` | `--user-installed-file PATH` | Добавляет пакеты из произвольного списка (по одному имени на строку). |
| `user_installed_packages` | `-x`, `--exclude PATTERN` | Исключает пакеты по шаблону (аргумент можно повторять). |
| `user_installed_packages` | `--include-auto-deps` | Включает зависимости, помеченные `Auto-Installed: yes`. |
| `user_installed_packages` | без аргументов | Анализирует текущую систему и выводит отсортированные команды `opkg update` и `opkg install …`. |

## Версионирование и релизы
- Текущая версия хранится в файле `VERSION` в корне репозитория.
- Оба скрипта поддерживают флаги `-V`/`--version` для быстрого вывода версии без запуска основной логики.
- Workflow [`Release`](.github/workflows/release.yml) использует [release-please](https://github.com/googleapis/release-please) для формирования GitHub Releases, обновления `CHANGELOG.md` и автоматической публикации архивов со скриптами.

## Примеры
### SCP и удалённая выгрузка
```sh
openwrt_full_backup --ssh-host 192.168.1.1 --ssh-port 2222 --ssh-user root
# Скрипт напечатает команду вида:
# scp -P 2222 root@192.168.1.1:/tmp/fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz <destination>
# На локальной машине выполните команду, заменив <destination> на каталог для сохранения архива:
scp -P 2222 \
    root@192.168.1.1:/tmp/fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz \
    ~/Backups/
```
Используйте `--emit-scp-cmd`, чтобы получить только подготовленную команду (например, для копирования в буфер обмена или добавления в автоматизацию):
```sh
openwrt_full_backup --emit-scp-cmd --ssh-host router.lan --ssh-port 2222 > /tmp/scp-command.txt
# Откройте файл, замените <destination> на нужный путь и выполните команду на своей машине.
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
openwrt_full_restore --dry-run --archive /tmp/fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz

# Применяем восстановление с автоматическим подтверждением и переустановкой пакетов
openwrt_full_restore --yes --archive /tmp/fullbackup_OpenWrt_24.10.4_2024-10-20_12-30-00.tar.gz --packages /tmp/opkg-user-packages.sh
```
После применения проверьте отчёт: он покажет путь к резервным копиям перезаписанных файлов (`/tmp/openwrt-restore-backup-*`) и список служб, которые были перезапущены.

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

# LuCI translations (1)
luci-i18n-firewall-ru

opkg update
opkg install bash htop luci-app-sqm luci-theme-material smartmontools tailscale
opkg install luci-i18n-firewall-ru
```

Можно, например, скрыть локализации (`user_installed_packages --exclude 'luci-i18n-*'`) или вернуть зависимости, помеченные `Auto-Installed: yes` (`user_installed_packages --include-auto-deps`).

## Тестирование
Фикстуры в `tests/fixtures/` и скрипт `tests/user_installed_packages_test.sh` проверяют сценарии генерации списка пакетов end-to-end. Тесты запускаются в CI и помогают избежать регрессий.

```sh
./tests/user_installed_packages_test.sh
```

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

Скрипты распространяются «как есть». Будем рады обратной связи и улучшениям через Pull Request.
