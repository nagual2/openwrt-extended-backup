# OpenWrt erweitertes Backup-Toolkit

[English](README.md) | [Русский](README.ru.md) | **Deutsch**  
*[Contributing](docs/CONTRIBUTING.md) | [Участие](docs/CONTRIBUTING.ru.md) | [Mitwirken](docs/CONTRIBUTING.de.md) · [Security Audit](docs/SECURITY_AUDIT_FIXES.md) | [Аудит](docs/SECURITY_AUDIT_FIXES.ru.md) | [Audit](docs/SECURITY_AUDIT_FIXES.de.md)*

[![CI](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/nagual2/openwrt-extended-backup/actions/workflows/ci.yml)

Eine Sammlung von POSIX-Shell-Dienstprogrammen, die direkt auf OpenWrt-Routern ausgeführt werden. Die Tools helfen beim Exportieren des beschreibbaren Overlays, der sicheren Wiederherstellung eines gespeicherten Archivs und der Aufzeichnung der Liste der manuell installierten Pakete.

> Die CLI-Ausgabe ist derzeit auf Russisch. Das Verhalten und die Optionen sind unten auf Englisch dokumentiert, bis die Lokalisierung aktualisiert wird.

## Was ist enthalten

| Befehl | Zweck |
| --- | --- |
| `openwrt_full_backup` | Erstellt ein tar.gz-Archiv von `/overlay`, gibt einen scp-Befehl aus und kann das Ergebnis über eine temporäre SMB-Freigabe über `ksmbd` bereitstellen. |
| `openwrt_restore` | Überprüft ein Backup-Archiv, extrahiert es in das Ziel-Overlay, behält Snapshots des aktuellen Zustands bei und führt optional gespeicherte Paketinstallationsskripte erneut aus. |
| `user_installed_packages` | Erstellt ein deterministisches Reinstallationskript für Pakete, die manuell mit `opkg` installiert wurden, mit optionalen Filtern und externen Paketlisten. |

Alle Skripte befinden sich in [`scripts/`](./scripts/) und teilen Hilfsfunktionen unter [`scripts/lib`](./scripts/lib). Dünne Launcher halten die Legacy-Befehlsnamen nach dem Refactoring verfügbar.

## Anforderungen

- OpenWrt 22.03 oder neuer mit BusyBox ≥ 1.35.
- `tar`, `coreutils-sha256sum` und Standard-OpenWrt-Basisdienstprogramme.
- Optional: `ksmbd-tools` zum Bereitstellen von SMB-Freigaben aus dem Backup-Skript.
- Root-Zugriff beim Wiederherstellen von Archiven oder Schreiben in `/overlay`.

## Installation

### Aus einem Release herunterladen

1. Holen Sie sich das neueste `.tar.gz` oder `.zip` aus [GitHub Releases](https://github.com/nagual2/openwrt-extended-backup/releases).
2. Extrahieren Sie das Archiv – es enthält nur das `scripts/`-Verzeichnis plus die Dokumentation.
3. Kopieren Sie die benötigten Skripte auf den Router (z.B. mit `scp`) und machen Sie sie mit `chmod +x` ausführbar.

### .ipk bauen und installieren

```
make ipk            # baut dist/openwrt-extended-backup_<version>-1_all.ipk
make install        # installiert das generierte Paket mit opkg, falls verfügbar
```

Setzen Sie `WITH_KSMBD=0`, wenn das Paket nicht von `ksmbd-tools` abhängen soll.

### Manuelle Installation

```
scp scripts/openwrt_full_backup root@<router>:/usr/sbin/
scp scripts/openwrt_restore root@<router>:/usr/sbin/
scp scripts/user_installed_packages root@<router>:/usr/bin/
chmod +x /usr/sbin/openwrt_full_backup /usr/sbin/openwrt_restore /usr/bin/user_installed_packages
```

## Verwendung

### `openwrt_full_backup`

```
openwrt_full_backup [--output PFAD] [--overlay VERZEICHNIS] [--export=smb] [--dry-run]
```

- `--output PFAD` – Verzeichnis, in das das tar.gz-Archiv geschrieben wird (Standard `/tmp`).
- `--overlay VERZEICHNIS` – benutzerdefiniertes Overlay-Quellverzeichnis (Standard `/overlay`).
- `--export=smb` – das resultierende Archiv über eine temporäre `ksmbd`-Freigabe bereitstellen.
- `--dry-run` – Anforderungen überprüfen und Aktionen anzeigen, ohne das Archiv zu erstellen.
- `-V/--version`, `-h/--help` – Version oder Hilfetext ausgeben.

Der Befehl gibt den absoluten Pfad zum generierten Archiv und einen `scp`-Befehl aus, der von einer Workstation ausgeführt werden kann. Wenn SMB-Export aktiviert ist, werden auch die Anmeldeinformationen und der Freigabepfad ausgegeben.

### `openwrt_restore`

```
openwrt_restore [--archive PFAD] [--packages PFAD] [--dry-run] [--no-reboot]
                 [--overlay VERZEICHNIS] [--force]
```

- `--archive PFAD` – Speicherort des Backup-Archivs zur Wiederherstellung. Fragt interaktiv nach, wenn nicht angegeben.
- `--packages PFAD` – Skript mit `opkg`-Befehlen zur Neuinstallation von Paketen nach der Overlay-Wiederherstellung.
- `--dry-run` – Archiv überprüfen, Bericht erstellen und ohne Systemmodifikation stoppen.
- `--no-reboot` – automatischen Neustart nach Abschluss der Wiederherstellung überspringen.
- `--overlay VERZEICHNIS` – Overlay-Mount-Punkt überschreiben (nützlich für Tests oder Recovery-Images).
- `--force` – Umgebungsprüfungen umgehen, die normalerweise gegen die Ausführung außerhalb von OpenWrt schützen.
- `-V/--version`, `-h/--help` – Version oder Hilfetext ausgeben.

Der Wiederherstellungsworkflow überprüft das Tarball, prüft optional SHA-256-Prüfsummen, extrahiert das Archiv in einen temporären Arbeitsbereich, erstellt einen Snapshot des aktuellen Overlays, kopiert Dateien mit erhaltenen Besitzern und Modi und startet Schlüsseldienste neu. Wenn kein `--packages`-Argument angegeben ist, verwendet es `user_installed_packages`, um das Reinstallationskript automatisch neu zu generieren.

### `user_installed_packages`

```
user_installed_packages [--status-file PFAD] [--user-installed-file PFAD]
                        [--include-auto-deps[=BOOL]] [--output PFAD]
                        [-x MUSTER]
```

- `--status-file PFAD` – alternative `opkg`-Statusdatei (Standard `/usr/lib/opkg/status`).
- `--user-installed-file PFAD` – zusätzliche Paketnamen aus einer externen Liste zusammenführen.
- `-x/--exclude MUSTER` – Pakete ausschließen, die einem Shell-Glob entsprechen (wiederholbar).
- `--include-auto-deps[=BOOL]` – Einträge mit Markierung `Auto-Installed: yes` einschließen.
- `--output PFAD` – Ausgabe in eine Datei schreiben (`-` lässt stdout).
- `-V/--version`, `-h/--help` – Version oder Hilfetext ausgeben.

Das Skript gibt gruppierte, sortierte Paketnamen gefolgt von sofort ausführbaren `opkg install`-Befehlen aus. Wenn die Statusdatei fehlt, fällt es auf `opkg list-installed` zurück, um auf Minimalsystemen zu funktionieren.

## Entwicklung

```
make fmt    # Shell-Skripte mit shfmt -w formatieren
make lint   # ShellCheck gegen alle ausführbaren Shell-Skripte ausführen
make test   # Bats-Testsuite ausführen
make all    # Kurzform für "make lint test"
```

Die Release-Paketierung (`make ipk`) installiert `openwrt_full_backup`, `openwrt_restore`, den Kompatibilitäts-Launcher `openwrt_full_restore` und `user_installed_packages` zusammen mit der Dokumentation. GitHub Releases veröffentlichen denselben Satz an Runtime-Dateien ohne die Development-Helfer oder Tests.

## Lizenz

Dieses Projekt wird unter den Bedingungen der [MIT License](./LICENSE) vertrieben.
