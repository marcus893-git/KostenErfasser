# KostenErfasser

Native iPhone-App (SwiftUI) zur privaten Ausgabenerfassung mit Belegscan per Kamera und Auswertungen. Alle Daten lokal auf dem Gerät, keine Server, keine Web-APIs. Installation ohne App Store über Xcode mit kostenloser Apple-ID (7-Tage-Signatur, kein iCloud/CloudKit möglich). Zielgerät: iPhone 16 mit iOS 26, Mindestversion iOS 26 (neue APIs wie Vision RecognizeDocumentsRequest und Foundation Models ohne Verfügbarkeitsprüfung für ältere Systeme nutzbar; Foundation Models trotzdem auf Verfügbarkeit des Modells prüfen).

Konzept und getroffene Entscheidungen: `docs/konzept/` (Teil 1 Produkt, Teil 2 Technik, Teil 3 Umgebung und Installation). Ausbaustufen 0 bis 4 stehen in Teil 1.

## Aufbau

- `Sources/KostenErfasserCore/`: gesamte Fachlogik als Swift-Paket. Nur Foundation, keine Apple-only-Frameworks (kein SwiftUI, SwiftData, UIKit, Vision, Charts), damit es unter Linux baut und testet.
  - `Models/`: `Money`, `PaymentMethod`, `Period`
  - `Receipt/`: Belegerkennung, derzeit `AmountParser`
  - `Categories/`: `DefaultCategories`
- `Tests/KostenErfasserCoreTests/`: Swift Testing (`import Testing`, `@Test`, `#expect`).
- `App/` (ab Stufe 1): Xcode-Projekt mit synchronisierten Ordnern; SwiftUI, SwiftData, VisionKit/Vision, Swift Charts. Bindet das Paket lokal ein.

## Befehle

```bash
swift build
swift test
swift format lint --strict --recursive Package.swift Sources Tests
swift format -i --recursive Package.swift Sources Tests
```

Vor jedem Commit müssen `swift test` und der Lint ohne Fehler laufen; die CI (`.github/workflows/ci.yml`) prüft beides.

## Regeln

- Beträge immer als `Money` (Int64-Cent), nie `Double` oder `Float`.
- Datumslogik mit `Calendar.kostenErfasser()` (Woche beginnt Montag, ISO-Wochen). Zeiträume sind halboffen `[start, end)`.
- Swift 6 Language Mode: Typen im Kernpaket sind `Sendable`-Werttypen.
- Rohwerte gespeicherter Enums (z. B. `PaymentMethod`) nie ändern; ein Test sichert das ab.
- Code, Bezeichner und Kommentare auf Englisch, Texte für die Oberfläche und Dokumentation auf Deutsch.
- Keine externen Abhängigkeiten ohne Rückfrage.
- Testdaten von echten Belegen nur anonymisiert einchecken.

## Cloud-Umgebung

Cloud-Sessions laufen unter Linux (Ubuntu 24.04) in der Umgebung „KostenErfasser“; das Setup-Skript installiert Swift 6.4.3. Das Kernpaket lässt sich dort bauen und testen, die iOS-App nicht (Xcode/macOS nötig). SwiftUI-Code kann hier geschrieben, aber nicht kompiliert werden: solchen Code klein halten und die Logik ins Kernpaket legen.
