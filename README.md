# KostenErfasser

Private Ausgabenerfassung fürs iPhone: Ausgaben manuell oder per Kamera erfassen (Endsumme, Firma und Datum werden vom Kassenzettel gelesen), nach Kategorien ordnen und nach Zeiträumen auswerten. Alle Daten bleiben auf dem iPhone. Installiert wird ohne App Store mit einer kostenlosen Apple-ID über SideStore; GitHub baut die App automatisch. Anleitung: [docs/INSTALLATION.md](docs/INSTALLATION.md).

## Stand

Stufe 1 (MVP) ist in Arbeit: manuelle Erfassung, Ausgabenliste mit Suche, Monatsübersicht, Statistik nach Kategorien und Zeiträumen, CSV-Export. Die Fachlogik liegt im Swift-Paket `KostenErfasserCore` und ist mit Unit-Tests abgedeckt.

## Aufbau

| Pfad | Inhalt |
|------|--------|
| `Package.swift`, `Sources/KostenErfasserCore/` | Fachlogik, nur Foundation, läuft auf iOS, macOS und Linux |
| `Tests/KostenErfasserCoreTests/` | Unit-Tests mit Swift Testing |
| `App/project.yml`, `App/KostenErfasser/` | iOS-App mit SwiftUI, SwiftData und Swift Charts; Projekt wird mit XcodeGen erzeugt |
| `docs/konzept/` | Gesamtkonzept, technisches Konzept, Cloud-Umgebung und Installation |
| `.github/workflows/ci.yml` | Lint und Tests bei jedem Push (Linux) |
| `.github/workflows/ios-app.yml` | baut die App auf macOS und stellt `KostenErfasser.ipa` bereit |
| `docs/INSTALLATION.md` | Installation auf dem iPhone mit SideStore |

## Befehle

```bash
swift build                                                       # Paket bauen
swift test                                                        # Tests ausführen
swift format lint --strict --recursive Package.swift Sources Tests App # Formatierung prüfen
swift format -i --recursive Package.swift Sources Tests App            # Formatierung korrigieren
```

Benötigt wird Swift 6 (in Xcode enthalten, unter Linux über swift.org). Die App selbst baut die CI; auf einem Mac ginge es mit `brew install xcodegen && xcodegen generate --spec App/project.yml`.

## Konzept

- [Gesamtkonzept](docs/konzept/01-gesamtkonzept.md): Funktionen, Kategorien, Auswertungen, Bedienung, Ausbaustufen, Entscheidungen
- [Technisches Konzept](docs/konzept/02-technisches-konzept.md): Architektur, Datenmodell, Belegerkennung, Statistik
- [Cloud-Umgebung, Entwicklung und Installation](docs/konzept/03-cloud-umgebung-und-installation.md): Setup der Cloud-Umgebung und Installation auf dem iPhone
