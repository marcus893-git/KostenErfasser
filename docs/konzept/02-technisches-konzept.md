# KostenErfasser: Technisches Konzept

Stand: 21.11.2026 (Fassung im Repository; das Original liegt in Google Drive unter Claude/KostenErfasser). Teil 2 von 3. Er baut auf dem Gesamtkonzept (Teil 1) auf.

## Architektur im Überblick

Die App besteht aus zwei Teilen. Ein plattformunabhängiges Swift-Paket (KostenErfasserCore) enthält die gesamte Fachlogik. Die iOS-App übernimmt Oberfläche, Speicherung und Kamera. Das Paket nutzt nur Foundation und lässt sich deshalb auch unter Linux in der Cloud-Umgebung bauen und testen. Alles, was Apple-Frameworks braucht (SwiftUI, SwiftData, VisionKit, Vision, Swift Charts), liegt in der App und wird auf dem Mac gebaut.

| Baustein                                                       | Ort         | Technik                                   | In der Cloud testbar |
|----------------------------------------------------------------|-------------|-------------------------------------------|----------------------|
| Datenmodelle als Werttypen (Betrag, Ausgabe-Entwurf, Zeitraum) | Swift-Paket | Swift, Foundation                         | ja                   |
| Beleg-Parser für Summe, Firma und Datum                        | Swift-Paket | Regex, Heuristiken, Plausibilitätsprüfung | ja                   |
| Kategorie-Vorschlag                                            | Swift-Paket | Händlerliste, gelernte Zuordnungen        | ja                   |
| Statistik-Engine                                               | Swift-Paket | Aggregation, Vergleiche, Prognose         | ja                   |
| CSV-Export und Backup-Format                                   | Swift-Paket | Codable, JSON                             | ja                   |
| Speicherung                                                    | App         | SwiftData                                 | nein, Mac            |
| Oberfläche und Diagramme                                       | App         | SwiftUI, Swift Charts                     | nein, Mac            |
| Scanner und Texterkennung                                      | App         | VisionKit, Vision                         | nein, Mac und iPhone |
| App-Sperre                                                     | App         | LocalAuthentication                       | nein, Mac            |

## Projektstruktur im Repository

    KostenErfasser/
      Package.swift                  Swift-Paket KostenErfasserCore
      Sources/KostenErfasserCore/
        Models/                      Money, ExpenseDraft, Zeitraum-Helfer
        Receipt/                     ReceiptParser, AmountParser, MerchantDetector, DateDetector
        Categories/                  CategorySuggester, Standardkategorien
        Statistics/                  StatisticsEngine, PeriodComparison, Forecast
        Export/                      CSVExporter, BackupFormat
      Tests/KostenErfasserCoreTests/
        Fixtures/                    anonymisierte OCR-Texte echter Belege
      App/
        KostenErfasser.xcodeproj     Xcode-Projekt mit synchronisierten Ordnern
        KostenErfasser/              SwiftUI-Views, SwiftData-Modelle, Scanner
        KostenErfasserUITests/       UI-Tests
      docs/                          Konzept und Entscheidungen
      .github/workflows/ci.yml       Linux: swift test, macOS: xcodebuild

Das Xcode-Projekt nutzt synchronisierte Ordner (ab Xcode 16): Neue Dateien in einem Ordner gehören automatisch zum Target. So kann Code in der Cloud-Umgebung angelegt werden, ohne die Projektdatei zu bearbeiten. Die App bindet KostenErfasserCore als lokales Paket ein. Externe Abhängigkeiten gibt es keine.

## Datenmodell

Beträge werden als ganze Cent (Int64) gespeichert, nie als Gleitkommazahl. So entstehen keine Rundungsfehler beim Summieren. Die Währung ist zunächst immer EUR, das Feld ist für Fremdwährungen vorbereitet.

### Ausgabe (Expense)

| Feld                 | Typ           | Pflicht | Bemerkung                                                               |
|----------------------|---------------|---------|-------------------------------------------------------------------------|
| id                   | UUID          | ja      | eindeutige Kennung, auch für Backup und späteren Sync                   |
| amountCents          | Int64         | ja      | Bruttobetrag in Cent, negativ für Gutschriften                          |
| currency             | String        | ja      | ISO-Code, vorerst „EUR“                                                 |
| date                 | Date          | ja      | Belegdatum                                                              |
| title                | String        | ja      | Beschreibung                                                            |
| merchant             | String        | nein    | Firma bzw. Händler                                                      |
| category             | Category      | ja      | Beziehung, auch auf eine Unterkategorie                                 |
| paymentMethod        | Enum          | nein    | bar, girocard, kreditkarte, paypal, ueberweisung, lastschrift, sonstige |
| note                 | String        | nein    | freie Notiz                                                             |
| tags                 | \[Tag\]       | nein    | z\. B. „Steuer“, „Urlaub 2027“                                          |
| receipt              | Receipt       | nein    | Beleg mit Bild und Erkennungsdaten                                      |
| recurringRule        | RecurringRule | nein    | gesetzt, wenn aus Fixkosten erzeugt                                     |
| splitGroupId         | UUID          | nein    | verbindet die Teilbuchungen eines aufgeteilten Belegs                   |
| source               | Enum          | ja      | manuell, scan, import, wiederkehrend                                    |
| createdAt, updatedAt | Date          | ja      | Zeitstempel                                                             |

### Weitere Entitäten

| Entität       | Wichtige Felder                                                                                                 |
|---------------|-----------------------------------------------------------------------------------------------------------------|
| Category      | name, symbolName (SF Symbol), colorHex, sortOrder, parent (für Unterkategorien), isArchived, monthlyBudgetCents |
| Tag           | name                                                                                                            |
| Receipt       | imageData (externe Speicherung), pageCount, ocrText, erkannte Felder mit Konfidenz, Parser-Version              |
| RecurringRule | title, amountCents, category, interval (monatlich, vierteljährlich, jährlich), nextDueDate, autoCreate          |
| MerchantRule  | normalisierter Händlername, category, hitCount (gelernte Zuordnung)                                             |

Kategorien werden archiviert statt gelöscht, damit alte Auswertungen stimmen. Änderungen am Schema laufen über SwiftData-Migrationspläne (VersionedSchema), damit vorhandene Daten bei Updates erhalten bleiben. Die Parser-Version am Beleg erlaubt es, alte Belege nach einer Verbesserung des Parsers neu auszuwerten.

## Belegerkennung

### Ablauf

1.  Aufnahme: VNDocumentCameraViewController (VisionKit) liefert entzerrte Seitenbilder. Alternativ wählt der PhotosPicker ein vorhandenes Foto, oder PDFKit liest eine PDF-Rechnung. Hat die PDF eingebetteten Text, wird dieser direkt genutzt.
2.  Texterkennung: Vision RecognizeTextRequest mit der Stufe „accurate“, den Sprachen de-DE und en-US und eingeschalteter Sprachkorrektur. Das Ergebnis sind Textzeilen mit Position und Konfidenz.
3.  Übergabe an den Parser im Swift-Paket als einfache Struktur (Text, Rahmen auf 0 bis 1 normiert, Konfidenz). Der Parser kennt keine Apple-Frameworks und ist deshalb unter Linux testbar.
4.  Felderkennung nach den Regeln unten. Jedes Feld liefert Wert, Konfidenz und Quellzeile.
5.  Prüfmaske in der App. Korrekturen der Kategorie fließen in die MerchantRule ein.

### Regeln für die Felderkennung

| Feld           | Vorgehen                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Endsumme       | Zeilen mit Schlüsselwörtern wie SUMME, GESAMT, ZU ZAHLEN, ENDBETRAG, RECHNUNGSBETRAG, TOTAL oder BETRAG EUR. Der Betrag steht rechts in derselben Zeile oder in der nächsten. Zeilen mit MwSt, Netto, Steuer, Rabatt oder Pfand werden ausgeschlossen. Plausibilitätsprüfung: „Gegeben“ minus „Rückgeld“, der Kartenbetrag (girocard, EC, VISA) und die Summe der Steuerzeilen müssen zur Summe passen. Ohne Schlüsselwort gilt der größte Betrag im unteren Drittel, mit niedriger Konfidenz.       |
| Betragsformat  | Deutsche und englische Schreibweise (1.234,56 und 1234.56), mit oder ohne EUR bzw. €, negative Beträge für Gutschriften.                                                                                                                                                                                                                                                                                                                                                                             |
| Firma          | Obere 25 % des Belegs. Zeilen mit Adresse (fünfstellige PLZ, Straße), Telefonnummer, Öffnungszeiten, URL oder USt-IdNr. werden übersprungen. Die erste verbleibende markante Zeile, oft in Großbuchstaben, ist der Kandidat. Abgleich mit einer Liste bekannter Händler (REWE, EDEKA, ALDI, Lidl, Kaufland, Netto, dm, Rossmann, Aral, Shell, IKEA und weitere) und mit den bereits gelernten Händlern. Ein Treffer erhöht die Konfidenz. Als Rückfall dient die Domain aus einer URL auf dem Beleg. |
| Datum          | Formate TT.MM.JJJJ, TT.MM.JJ und JJJJ-MM-TT, auch mit Uhrzeit. Bevorzugt wird ein Datum neben dem Wort „Datum“ oder neben einer Uhrzeit. Ein Datum in der Zukunft oder älter als zwei Jahre senkt die Konfidenz. Ohne Treffer wird das heutige Datum vorgeschlagen.                                                                                                                                                                                                                                  |
| Zahlungsart    | Schlüsselwörter BAR, Gegeben, girocard, EC, VISA, Mastercard, kontaktlos, PayPal.                                                                                                                                                                                                                                                                                                                                                                                                                    |
| Mehrwertsteuer | Zeilen mit 7 % und 19 % mit Netto- und Steuerbetrag. Optional, für spätere Auswertungen.                                                                                                                                                                                                                                                                                                                                                                                                             |

Qualitätsziel für den Parser: Auf einer Sammlung von mindestens 50 anonymisierten Belegen soll die Summe in 95 % und die Firma in 85 % der Fälle richtig erkannt werden. Die Belege liegen als OCR-Text im Repository und werden bei jedem Push geprüft.

### Erweiterungen ab iOS 26

- Vision RecognizeDocumentsRequest erkennt zusätzlich die Struktur eines Dokuments, etwa Tabellenzeilen. Das hilft, Beträge den richtigen Positionen zuzuordnen.
- Auf iPhones mit Apple Intelligence (ab iPhone 15 Pro) kann das Foundation-Models-Framework die Felder aus dem erkannten Text strukturiert auslesen. Das Sprachmodell läuft lokal und kostenlos. Die Regel-Erkennung bleibt die Grundlage, das Ergebnis des Modells wird nur übernommen, wenn es plausibel ist: Der Betrag muss im Text vorkommen und das Datum gültig sein.

## Statistik-Engine

Die Engine arbeitet auf einfachen Werttypen (Betrag, Datum, Kategorie-ID, Händler, Zahlungsart) und ist damit unabhängig von SwiftData. Die App lädt die Ausgaben eines Zeitraums und übergibt sie.

| Funktion                                 | Ergebnis                                                                                       |
|------------------------------------------|------------------------------------------------------------------------------------------------|
| Summen nach Kategorie und Unterkategorie | Betrag, Anteil, Anzahl                                                                         |
| Zeitreihe nach Tag, Woche oder Monat     | Summe je Intervall, wahlweise je Kategorie                                                     |
| Periodenvergleich                        | Vorperiode und Vorjahreszeitraum, Differenz absolut und in Prozent                             |
| Kumulierter Verlauf                      | Laufende Summe im Monat, Vergleich mit dem Vormonat am selben Tag                              |
| Prognose Monatsende                      | Bisherige variable Ausgaben auf die Tage des Monats hochgerechnet, plus noch fällige Fixkosten |
| Händler-Ranking                          | Summe, Anzahl, Durchschnitt und Median je Händler                                              |
| Budgetstatus                             | Verbraucht, Rest, Ampel: grün unter 80 %, gelb bis 100 %, rot darüber                          |
| Verteilungen                             | Nach Wochentag und Zahlungsart                                                                 |

Zeiträume werden mit dem Kalender für das Gebietsschema de_DE gebildet, die Woche beginnt am Montag. Die Tests decken Monatswechsel, Schaltjahre und die Zeitumstellung ab. Dargestellt werden die Ergebnisse mit Swift Charts: Ring- oder Balkendiagramm für Kategorien, gestapelte Balken für den Monatsverlauf und eine Linie für den kumulierten Verlauf.

## Qualitätssicherung

- Unit-Tests für das Swift-Paket mit Swift Testing, lauffähig unter Linux in der Cloud und auf dem Mac.
- Formatierung und Lint mit swift-format, das in der Swift-Toolchain enthalten ist.
- UI-Tests der wichtigsten Abläufe (manuell erfassen, Scan mit Testbild, Statistik) im iOS-Simulator auf dem Mac.
- GitHub Actions: ein Linux-Job führt bei jedem Push swift test aus. Ein macOS-Job baut die App nur bei Pull Requests, weil macOS-Minuten bei privaten Repositories zehnfach angerechnet werden.

## Technische Eckdaten

| Thema                  | Festlegung                                         |
|------------------------|----------------------------------------------------|
| Sprache                | Swift 6 mit strikter Concurrency-Prüfung           |
| Mindestversion         | iOS 18 (iPhone XS, XR, SE 2. Generation und neuer) |
| Oberfläche             | SwiftUI, Swift Charts                              |
| Speicherung            | SwiftData, Belegbilder als externe Daten           |
| Texterkennung          | Vision auf dem Gerät, VisionKit-Dokumentenscanner  |
| Externe Abhängigkeiten | keine                                              |
| Sprache der App        | Deutsch, Beträge und Datumsformate nach de_DE      |
