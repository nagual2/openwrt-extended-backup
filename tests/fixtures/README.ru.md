# Тестовые фикстуры

[English](README.md) | **Русский** | [Deutsch](README.de.md)

Эта директория содержит файлы данных, используемые тестовым набором Bats.

- `system/openwrt_release` — репрезентативное содержимое `/etc/openwrt_release`, используемое тестами `openwrt_full_backup`.
- `opkg/status.sample` и связанные файлы — базовый набор фикстур, покрывающий сценарии по умолчанию, исключённые переводы LuCI и авто-зависимости из оригинального smoke-теста.
- `opkg/status.special.sample` / `user-installed-special.list` / `expected-special.txt` — обрабатывают имена пакетов со специальными символами (`+`, `@`) и дополнительные пользовательские списки.
- `opkg/status.none.sample` / `expected-none.txt` — минимальная база данных `opkg` без установленных пользователем пакетов для негативного покрытия.
