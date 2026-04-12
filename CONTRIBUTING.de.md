# Beitrag zu openwrt-extended-backup

Vielen Dank für Ihr Interesse an einem Beitrag! Dieses Dokument enthält Richtlinien für Beiträge zum Projekt.

## Verhaltenskodex

Bitte seien Sie in allen Interaktionen respektvoll und konstruktiv.

## Sicherheit zuerst

**WICHTIG: Sicherheit hat oberste Priorität.** Bitte lesen Sie vor einem Beitrag [SECURITY.md](./SECURITY.md).

### Kritische Sicherheitsregeln

1. **Niemals Anmeldeinformationen oder Geheimnisse committen:**
   - API-Schlüssel, GitHub-Tokens, SSH-Private-Keys
   - Passwörter (verwenden Sie stattdessen Testwerte oder Umgebungsvariablen)
   - AWS-Anmeldeinformationen oder andere Cloud-Geheimnisse
   - Jegliche personenbezogenen Daten

2. **SSH für Git-Operationen verwenden:**
   - Git für SSH konfigurieren: `git clone git@github.com:...`
   - NICHT HTTPS mit eingebetteten Anmeldeinformationen verwenden

3. **Sensible Daten schützen:**
   - Anmeldeinformationen in `.env`-Dateien speichern (zu `.gitignore` hinzufügen)
   - Umgebungsvariablen in Tests verwenden
   - `.env.example` für Test-Setup referenzieren

4. **Testanmeldeinformationen dürfen nicht echt aussehen:**
   - Mock-Werte wie `TestPass${RANDOM}` in Tests verwenden
   - Platzhalterwerte verwenden, die klar auf Testen hinweisen
   - Eindeutige Werte pro Testlauf generieren, wenn möglich

5. **Pre-Commit-Hooks prüfen auf Geheimnisse:**
   - Sicherstellen, dass alle Hooks vor dem Push bestehen
   - `gitleaks` verwenden, um versehentlich committete Geheimnisse zu scannen
   - Erkannte Probleme vor dem PR-Submit beheben

## Erste Schritte

### Setup

1. Repository forken
2. Fork via SSH klonen:
   ```bash
   git clone git@github.com:your-username/openwrt-extended-backup.git
   cd openwrt-extended-backup
   ```

3. Feature-Branch erstellen:
   ```bash
   git checkout -b feature/your-feature
   ```

4. Entwicklungsabhängigkeiten installieren:
   ```bash
   # Pre-Commit-Hooks installieren
   pre-commit install
   ```

### Änderungen vornehmen

1. **Code folgt bestehenden Mustern** – Ähnlichen Code auf Stil/Konventionen prüfen
2. **Änderungen testen** – Tests ausführen, um sicherzustellen, dass nichts kaputt geht:
   ```bash
   make test
   ```

3. **Shell-Skripte linten** – Code-Qualität sicherstellen:
   ```bash
   make shellcheck
   ```

4. **Niemals Geheimnisse committen** – Diff sorgfältig überprüfen:
   ```bash
   git diff
   git diff --staged
   ```

## Testen

### Tests ausführen

```bash
# Alle Tests ausführen
make test

# Spezifische Testdatei ausführen
bats tests/openwrt_full_backup.bats

# Spezifischen Test ausführen
bats tests/openwrt_full_backup.bats -f "Testnamensmuster"
```

### Tests schreiben

- Deskriptive Testnamen verwenden
- Generierte/Mock-Anmeldeinformationen verwenden (niemals hardcodiert)
- Testartefakte bereinigen
- Bestehende Teststruktur folgen

Beispiel:
```bash
@test "Testbeschreibung" {
  # Eindeutige Testanmeldeinformationen generieren
  local test_password="TestPass${RANDOM}"
  export TEST_VAR="${test_password}"
  
  # Testcode
  
  # Bereinigung
  unset TEST_VAR
}
```

## Code-Stil

### Shell-Skripte

- Wo möglich POSIX sh verwenden
- Bestehende Formatierung und Namenskonventionen folgen
- Aussagekräftige Variablennamen verwenden
- Kommentare für komplexe Logik hinzufügen
- Shellcheck zur Validierung ausführen

### Allgemeine Richtlinien

- Ein Feature pro Pull Request
- Klare Commit-Nachrichten schreiben
- Verwandte Commits vor PR-Submit squashen
- README bei Feature-Hinzufügung aktualisieren
- CHANGELOG.md mit Änderungen aktualisieren

## Änderungen einreichen

### Vor dem Einreichen

1. ✅ Tests ausführen: `make test`
2. ✅ Shellcheck ausführen: `make shellcheck`
3. ✅ Diff überprüfen – keine Geheimnisse
4. ✅ Pre-Commit-Hooks bestehen
5. ✅ CHANGELOG.md und README bei Bedarf aktualisieren

### Pull Request erstellen

1. Feature-Branch pushen
2. Pull Request erstellen mit:
   - Klarer Beschreibung der Änderungen
   - Referenz auf verwandte Issues
   - Testabdeckungsinformationen
   - Screenshots für UI-Änderungen (falls zutreffend)

3. Prompt auf Code-Review-Feedback reagieren

## Probleme melden

- **Sicherheitsprobleme**: Siehe [SECURITY.md](./SECURITY.md)
- **Fehlerberichte**: Reproduzierbare Schritte und Kontext bereitstellen
- **Feature-Requests**: Use Case und erwartetes Verhalten beschreiben

## Fragen?

- Bestehende Issues und Discussions prüfen
- README und Dokumentation lesen
- Maintainer fragen, falls unklar

## Attribution

Mitwirkende werden in CHANGELOG.md und Projektdokumentation erwähnt.

Vielen Dank für Ihre Hilfe, dieses Projekt zu verbessern! 🎉
