# KostenErfasser

Native iPhone-App (SwiftUI) zur privaten Ausgabenerfassung mit Belegscan per Kamera und Auswertungen. Alle Daten lokal auf dem Gerät, keine Server, keine Web-APIs. Installation ohne App Store mit kostenloser Apple-ID über SideStore (7-Tage-Signatur, kein iCloud/CloudKit möglich, siehe `docs/INSTALLATION.md`). Es gibt keinen Mac: Die App wird nur in GitHub Actions gebaut (Workflow „iOS-App“, unsignierte IPA). Zielgerät: iPhone 16 mit iOS 26, Mindestversion iOS 26 (neue APIs wie Vision RecognizeDocumentsRequest und Foundation Models ohne Verfügbarkeitsprüfung für ältere Systeme nutzbar; Foundation Models trotzdem auf Verfügbarkeit des Modells prüfen).

Konzept und getroffene Entscheidungen: `docs/konzept/` (Teil 1 Produkt, Teil 2 Technik, Teil 3 Umgebung und Installation). Ausbaustufen 0 bis 4 stehen in Teil 1.

## Aufbau

- `Sources/KostenErfasserCore/`: gesamte Fachlogik als Swift-Paket. Nur Foundation, keine Apple-only-Frameworks (kein SwiftUI, SwiftData, UIKit, Vision, Charts), damit es unter Linux baut und testet.
  - `Models/`: `Money`, `PaymentMethod`, `Period`
  - `Receipt/`: Belegerkennung, derzeit `AmountParser`
  - `Categories/`: `DefaultCategories`
- `Tests/KostenErfasserCoreTests/`: Swift Testing (`import Testing`, `@Test`, `#expect`).
- `App/project.yml`: Projektbeschreibung für XcodeGen. Das Xcode-Projekt wird daraus in der CI erzeugt und nicht eingecheckt. Das Kernpaket ist dort als statische Bibliothek `KostenErfasserCore` eingebunden (`import KostenErfasserCore`).
- `App/KostenErfasser/`: iOS-App mit SwiftUI, SwiftData und Swift Charts.
  - `Model/`: SwiftData-Modelle `Expense`, `ExpenseCategory` (nicht `Category`, Namenskonflikt mit der ObjC-Runtime), `CategorySeeder`
  - `Views/`: Tabs Übersicht, Ausgaben, Erfassen, Statistik, Einstellungen
  - `Support/`: kleine Hilfen wie `Color(hex:)`

## Befehle

```bash
swift build
swift test
swift format lint --strict --recursive Package.swift Sources Tests App
swift format -i --recursive Package.swift Sources Tests App
swiftc -parse App/KostenErfasser/*.swift App/KostenErfasser/*/*.swift   # nur Syntax der App
```

Vor jedem Commit müssen `swift test`, der Lint und die Syntaxprüfung ohne Fehler laufen; `.github/workflows/ci.yml` prüft Lint und Tests unter Linux. Ob die App kompiliert, zeigt erst `.github/workflows/ios-app.yml` auf macOS: nach jedem Push mit App-Änderungen dessen Ergebnis prüfen und Fehler beheben, bevor weitere Funktionen dazukommen. macOS-Minuten sind bei privaten Repositories teuer, also Änderungen bündeln.

## Regeln

- Beträge immer als `Money` (Int64-Cent), nie `Double` oder `Float`.
- Datumslogik mit `Calendar.kostenErfasser()` (Woche beginnt Montag, ISO-Wochen). Zeiträume sind halboffen `[start, end)`.
- Swift 6 Language Mode: Typen im Kernpaket sind `Sendable`-Werttypen.
- Rohwerte gespeicherter Enums (z. B. `PaymentMethod`) nie ändern; ein Test sichert das ab.
- Code, Bezeichner und Kommentare auf Englisch, Texte für die Oberfläche und Dokumentation auf Deutsch.
- Keine externen Swift-Paket-Abhängigkeiten ohne Rückfrage. XcodeGen wird nur in der CI als Build-Werkzeug installiert.
- Testdaten von echten Belegen nur anonymisiert einchecken.

## Cloud-Umgebung

Cloud-Sessions laufen unter Linux (Ubuntu 24.04) in der Umgebung „KostenErfasser“; das Setup-Skript installiert Swift 6.4.3. Das Kernpaket lässt sich dort bauen und testen, die iOS-App nicht (Xcode/macOS nötig). SwiftUI-Code kann hier geschrieben, aber nicht kompiliert werden: solchen Code klein halten, nur gut bekannte APIs verwenden und die Logik ins Kernpaket legen.
