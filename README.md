# KostenErfasser

Private Ausgabenerfassung fürs iPhone: Ausgaben manuell oder per Kamera erfassen (Endsumme, Firma und Datum werden vom Kassenzettel gelesen), nach Kategorien ordnen und nach Zeiträumen auswerten. Alle Daten bleiben auf dem iPhone. Installiert wird ohne App Store über Xcode mit einer kostenlosen Apple-ID.

## Stand

Stufe 0 (Grundlage) ist umgesetzt: das Swift-Paket `KostenErfasserCore` mit Geldbeträgen in Cent, einem Betrags-Parser für deutsche und englische Schreibweise, Zeiträumen für Auswertungen, Zahlungsarten und den Standardkategorien. Die iOS-App folgt mit Stufe 1.

## Aufbau

| Pfad | Inhalt |
|------|--------|
| `Package.swift`, `Sources/KostenErfasserCore/` | Fachlogik, nur Foundation, läuft auf iOS, macOS und Linux |
| `Tests/KostenErfasserCoreTests/` | Unit-Tests mit Swift Testing |
| `App/` | iOS-App mit SwiftUI (ab Stufe 1) |
| `docs/konzept/` | Gesamtkonzept, technisches Konzept, Cloud-Umgebung und Installation |
| `.github/workflows/ci.yml` | Lint und Tests bei jedem Push |

## Befehle

```bash
swift build                                                       # Paket bauen
swift test                                                        # Tests ausführen
swift format lint --strict --recursive Package.swift Sources Tests # Formatierung prüfen
swift format -i --recursive Package.swift Sources Tests            # Formatierung korrigieren
```

Benötigt wird Swift 6 (in Xcode enthalten, unter Linux über swift.org).

## Konzept

- [Gesamtkonzept](docs/konzept/01-gesamtkonzept.md): Funktionen, Kategorien, Auswertungen, Bedienung, Ausbaustufen, Entscheidungen
- [Technisches Konzept](docs/konzept/02-technisches-konzept.md): Architektur, Datenmodell, Belegerkennung, Statistik
- [Cloud-Umgebung, Entwicklung und Installation](docs/konzept/03-cloud-umgebung-und-installation.md): Setup der Cloud-Umgebung und Installation auf dem iPhone
