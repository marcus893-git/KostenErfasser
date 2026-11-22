# KostenErfasser auf dem iPhone installieren (Xcode)

Stand: 22.11.2026. Gilt für das MacBook, ein iPhone 16 mit iOS 26 und eine kostenlose Apple-ID. Der Ausweichweg ohne Mac steht in [INSTALLATION-SIDESTORE.md](INSTALLATION-SIDESTORE.md).

## Voraussetzungen

- MacBook mit Xcode 26 oder neuer. Xcode 26 setzt macOS 15.6 oder neuer voraus.
- Großzügig freier Speicher auf dem MacBook, da Xcode und die iOS-Plattform zusammen viele GB belegen. Rund 30 GB sind ein guter Richtwert.
- Ein USB-C-Kabel für das iPhone und eine kostenlose Apple-ID.

## Einmalige Einrichtung auf dem MacBook

1. Xcode aus dem Mac App Store installieren und einmal starten. Fragt Xcode nach zusätzlichen Komponenten oder der iOS-Plattform, diese installieren.
2. In Xcode unter Xcode > Settings > Accounts mit „+“ die Apple-ID hinzufügen.
3. Das Terminal öffnen. Falls Homebrew noch fehlt, nach der Anleitung auf [brew.sh](https://brew.sh) installieren. Dann XcodeGen und das GitHub-Programm installieren:

   ```bash
   brew install xcodegen gh
   ```

4. Bei GitHub anmelden und das Projekt holen:

   ```bash
   gh auth login
   gh repo clone marcus893-git/KostenErfasser
   cd KostenErfasser
   git checkout claude/iphone-expense-tracker-cloud-hvfwyg
   ```

   Der letzte Befehl entfällt, sobald die Arbeit in den Hauptzweig übernommen ist.

5. Das Xcode-Projekt erzeugen und öffnen:

   ```bash
   ./App/generate.sh
   ```

## App zum ersten Mal auf das iPhone spielen

1. Das iPhone per Kabel anschließen, entsperren und „Diesem Computer vertrauen“ bestätigen.
2. Auf dem iPhone unter Einstellungen > Datenschutz & Sicherheit den Entwicklermodus einschalten, das iPhone neu starten und den Entwicklermodus bestätigen. Der Schalter erscheint erst, nachdem das iPhone einmal mit Xcode verbunden war.
3. In Xcode links auf das Projekt KostenErfasser klicken, das Target „KostenErfasser“ wählen und „Signing & Capabilities“ öffnen. Bei „Team“ deinen Namen mit dem Zusatz „(Personal Team)“ auswählen. Meldet Xcode, dass die Bundle-ID nicht verfügbar ist, bei „Bundle Identifier“ eine eigene eintragen, z. B. `de.deinname.kostenerfasser`.
4. Oben in der Xcode-Leiste dein iPhone als Ziel wählen und auf die Play-Taste klicken (Run, Tastenkürzel ⌘R). Der erste Build dauert eine Weile.
5. Beim ersten Start meldet das iPhone einen nicht vertrauenswürdigen Entwickler. Unter Einstellungen > Allgemein > VPN & Geräteverwaltung deine Apple-ID antippen und vertrauen. Danach startet die App.
6. Im Terminal noch einmal `./App/generate.sh` ausführen. Das Skript speichert Team und Bundle-ID in `App/Signing.local.xcconfig`, damit du sie nach dem Neuerzeugen des Projekts nicht wieder auswählen musst. Diese Datei bleibt nur auf dem MacBook.

## Alle 7 Tage erneuern

Die Signatur mit einer kostenlosen Apple-ID gilt 7 Tage. Danach startet die App nicht mehr, die Daten bleiben aber erhalten.

1. Im Terminal im Ordner KostenErfasser `./App/generate.sh` ausführen (oder das Projekt in Xcode über „Open Recent“ öffnen).
2. Das iPhone als Ziel wählen und auf Run klicken.

Nach der ersten Verbindung per Kabel klappt das auch über WLAN, solange MacBook und iPhone im selben Netz sind. Ob das iPhone per WLAN erreichbar ist, zeigt Xcode unter Window > Devices and Simulators. Eine Erinnerung im Kalender alle 6 Tage hilft, die Frist nicht zu verpassen.

## Neue Version einspielen

```bash
cd KostenErfasser
git pull
./App/generate.sh
```

Danach in Xcode auf Run klicken. Die Daten bleiben erhalten, solange die App nicht vom iPhone gelöscht wird und die Bundle-ID gleich bleibt.

## Grenzen der kostenlosen Apple-ID

- Die Installation gilt 7 Tage und muss dann aus Xcode erneuert werden.
- Höchstens 3 selbst installierte Apps gleichzeitig.
- Kein iCloud-Sync.
- Die Bundle-ID nach dem ersten Einrichten nicht mehr ändern: Mit einer neuen Bundle-ID entsteht eine neue App ohne die bisherigen Daten.

## Wenn etwas nicht klappt

| Meldung oder Problem | Lösung |
|----------------------|--------|
| Bundle-ID nicht verfügbar („Failed to register bundle identifier“) | Unter „Signing & Capabilities“ eine eigene Bundle-ID eintragen, danach `./App/generate.sh` ausführen. |
| Kein Team auswählbar („No Account for Team“) | Unter Xcode > Settings > Accounts die Apple-ID hinzufügen. |
| iPhone erscheint nicht in Xcode | Kabel prüfen, iPhone entsperren, dem Mac vertrauen, Entwicklermodus einschalten. |
| iOS-Plattform fehlt beim Bauen | In Xcode unter Settings > Components die iOS-Plattform laden. |
| „Nicht vertrauenswürdiger Entwickler“ auf dem iPhone | Einstellungen > Allgemein > VPN & Geräteverwaltung: der Apple-ID vertrauen. |
| App startet nicht mehr | Die 7 Tage sind abgelaufen. In Xcode erneut auf Run klicken, die Daten sind noch da. |
| `XcodeGen fehlt` im Terminal | `brew install xcodegen` ausführen. |
