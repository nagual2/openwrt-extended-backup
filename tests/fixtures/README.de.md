# Test-Fixtures

Dieses Verzeichnis enthält Datendateien, die vom Bats-Test-Consumer genutzt werden.

- `system/openwrt_release` – repräsentativer Inhalt von `/etc/openwrt_release`, der von `openwrt_full_backup`-Tests verwendet wird.
- `opkg/status.sample` und verwandte Dateien – Baseline-Fixture-Set, das Standard, ausgeschlossene LuCI-Übersetzungen und Auto-Dependency-Szenarien aus dem ursprünglichen Smoke-Test abdeckt.
- `opkg/status.special.sample` / `user-installed-special.list` / `expected-special.txt` – testen Paketnamen mit Sonderzeichen (`+`, `@`) und zusätzliche benutzerverwaltete Listen.
- `opkg/status.none.sample` / `expected-none.txt` – minimale `opkg`-Datenbank ohne benutzerinstallierte Pakete für negative Abdeckung.
