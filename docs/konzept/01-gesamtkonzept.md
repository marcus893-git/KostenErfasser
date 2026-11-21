# KostenErfasser: Gesamtkonzept

Stand: 21.11.2026 (Fassung im Repository; das Original liegt in Google Drive unter Claude/KostenErfasser). Teil 1 von 3. Teil 2 beschreibt die Technik, Teil 3 die Cloud-Umgebung, den Entwicklungsablauf und die Installation auf dem iPhone.

## Zusammenfassung

KostenErfasser wird eine native iPhone-App (SwiftUI) zur Erfassung privater Ausgaben. Alle Daten bleiben auf dem iPhone, es gibt keinen Server und kein Benutzerkonto. Kassenzettel und Rechnungen werden mit der Kamera gescannt. Die App liest Endsumme, Firma und Datum per Texterkennung direkt auf dem Gerät aus und schlägt eine Kategorie vor. Die Auswertungen zeigen Ausgaben nach Kategorien, Zeiträumen, Händlern und Zahlungsarten und vergleichen sie mit Vorperioden und Budgets.

Installiert wird die App ohne App Store über Xcode mit einer kostenlosen Apple-ID. Dafür ist ein Mac nötig, und die App muss alle 7 Tage neu aufgespielt werden. Mit der Apple-Developer-Mitgliedschaft (99 € pro Jahr) gilt eine Installation ein Jahr lang. Für den Fall, dass kein Mac verfügbar ist, beschreibt Teil 3 einen Weg über GitHub Actions und einen Windows-PC.

## Ziele und Rahmenbedingungen

- Schnelle Erfassung: eine manuelle Ausgabe in unter 10 Sekunden, ein Beleg-Scan einschließlich Prüfung in unter 20 Sekunden.
- Offline und privat: keine Cloud-Dienste, keine Werbung, keine Tracker. Die Texterkennung läuft auf dem iPhone.
- Verständliche Auswertungen, die drei Fragen beantworten: Wofür geht das Geld weg, was hat sich gegenüber früher verändert, und wo stehe ich gegenüber meinem Budget?
- Nutzung ohne App Store, zunächst für eine Person auf einem iPhone.
- Daten jederzeit exportierbar als CSV, PDF-Bericht und vollständiges Backup.

## Plattformentscheidung

Verglichen wurden drei Wege:

| Kriterium                             | Native App mit Mac                                                | Native App ohne Mac                                                | Web-App (PWA)                                    |
|---------------------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------|--------------------------------------------------|
| Installation                          | Xcode, kostenlose Apple-ID                                        | Build in GitHub Actions, Installation mit Sideloadly oder AltStore | In Safari zum Home-Bildschirm hinzufügen         |
| Mac nötig                             | ja                                                                | nein, ein Windows-PC reicht                                        | nein                                             |
| Gültigkeit der Installation           | 7 Tage (kostenlos), 1 Jahr (99 € pro Jahr)                        | 7 Tage                                                             | unbegrenzt                                       |
| Belegerkennung                        | Apple Vision, sehr gute Erkennung deutscher Belege, auf dem Gerät | wie mit Mac                                                        | Tesseract.js im Browser, langsamer und ungenauer |
| Dokumentenscanner mit Kantenerkennung | ja (VisionKit)                                                    | ja                                                                 | nein, nur ein normales Foto                      |
| Diagramme, Face ID, Widgets, Siri     | alles verfügbar                                                   | alles verfügbar                                                    | stark eingeschränkt                              |
| Hosting                               | keins                                                             | keins                                                              | HTTPS-Webspace nötig, z. B. GitHub Pages         |

Entscheidung: native SwiftUI-App. Die Belegerkennung ist die wichtigste Funktion, und Apples Vision-Framework erkennt Kassenzettel deutlich zuverlässiger als eine Browser-Lösung. Dazu kommen der Dokumentenscanner, Swift Charts und Face ID ohne Zusatzaufwand. Die Variante ohne Mac bleibt als Ausweichweg.

## Funktionsumfang

Dieser Abschnitt beschreibt das Zielbild. In welcher Reihenfolge die Funktionen kommen, steht unter Ausbaustufen.

### Ausgaben erfassen

- Felder: Betrag (Ziffernblock, Komma als Dezimaltrenner), Datum (vorbelegt mit heute), Kategorie und Unterkategorie, Beschreibung, Firma bzw. Händler, Zahlungsart, Notiz und Schlagwörter.
- Vorschläge aus der eigenen Historie: zuletzt genutzte Kategorien und Händler, automatische Vervollständigung der Beschreibung.
- Ausgabe duplizieren, nachträglich bearbeiten oder löschen.
- Einen Beleg auf mehrere Kategorien aufteilen, zum Beispiel einen Supermarkteinkauf auf Lebensmittel und Drogerie.
- Fixkosten und Abos als wiederkehrende Ausgaben (monatlich, vierteljährlich, jährlich). Sie werden automatisch oder nach Bestätigung angelegt.

### Belege per Kamera erfassen

- Dokumentenscanner mit automatischer Kantenerkennung und Entzerrung, auch für mehrseitige Rechnungen.
- Import von Fotos aus der Mediathek und von PDF-Rechnungen, etwa aus Mail über den Teilen-Dialog.
- Automatisch erkannt werden Endsumme, Firma und Datum. Wenn lesbar, zusätzlich Zahlungsart, enthaltene Mehrwertsteuer und Belegnummer.
- Prüfmaske: Die erkannten Werte sind vorausgefüllt, unsichere Felder sind farbig markiert. Ein Tipp auf ein Feld zeigt die Fundstelle im Belegbild.
- Die Kategorie wird anhand des Händlers vorgeschlagen. Die App lernt aus Korrekturen, so dass REWE künftig bei Lebensmittel und Aral bei Tanken landet.
- Das Belegbild wird komprimiert zur Ausgabe gespeichert und ist in der Detailansicht abrufbar.

### Kategorien

Beim ersten Start legt die App die folgenden Standardkategorien an. Name, Symbol, Farbe, Reihenfolge und Unterkategorien sind frei änderbar. Nicht mehr benötigte Kategorien werden archiviert statt gelöscht, damit alte Auswertungen stimmen.

| Kategorie               | Unterkategorien (Beispiele)                                    |
|-------------------------|----------------------------------------------------------------|
| Lebensmittel            | Supermarkt, Bäcker, Getränke, Wochenmarkt                      |
| Drogerie & Haushalt     | Drogerie, Reinigungsmittel, Haushaltswaren                     |
| Restaurant & Café       | Restaurant, Lieferdienst, Café, Kantine                        |
| Wohnen                  | Miete, Nebenkosten, Strom, Internet & Telefon, Rundfunkbeitrag |
| Mobilität               | Tanken, ÖPNV und Deutschlandticket, Bahn, Werkstatt, Parken    |
| Gesundheit              | Apotheke, Arzt, Brille, Fitness                                |
| Versicherungen          | Haftpflicht, Hausrat, Kfz, Zusatzversicherung                  |
| Freizeit & Hobby        | Kino, Konzerte, Sport, Bücher                                  |
| Kleidung & Schuhe       | keine                                                          |
| Elektronik & Software   | Geräte, Apps, Zubehör                                          |
| Abos & Mitgliedschaften | Streaming, Vereine, Zeitschriften                              |
| Urlaub & Reisen         | Unterkunft, Anreise, Aktivitäten                               |
| Geschenke & Spenden     | Geschenke, Spenden                                             |
| Bildung                 | Kurse, Fachbücher                                              |
| Sonstiges               | keine                                                          |

### Auswertungen

Die Übersicht beim Öffnen der App zeigt:

- Ausgaben im laufenden Monat, die Differenz zum Vormonat am selben Tag und eine Prognose bis Monatsende.
- Den Budgetstand je Kategorie mit Ampelfarbe.
- Die fünf größten Kategorien des Monats und die letzten Buchungen.

Der Statistikbereich arbeitet mit einem wählbaren Zeitraum (Woche, Monat, Quartal, Jahr oder frei) und bietet:

- Verteilung nach Kategorien mit Anteil und Betrag, mit Drilldown auf Unterkategorien und einzelne Ausgaben.
- Zeitverlauf: Monatssummen der letzten 12 Monate nach Kategorien gestapelt, Tageswerte innerhalb eines Monats und den kumulierten Monatsverlauf im Vergleich zum Vormonat.
- Vergleich mit der Vorperiode und dem Vorjahreszeitraum, absolut und in Prozent, für jede Kategorie.
- Händler-Ranking mit Summe, Anzahl der Einkäufe und durchschnittlichem Bon.
- Fixkosten gegenüber variablen Ausgaben und eine Liste aller Abos mit ihren Jahreskosten.
- Kennzahlen: Durchschnitt pro Tag und Monat, Median einer Ausgabe, größte Einzelausgaben und Anzahl der Buchungen.
- Verteilung nach Wochentagen und Zahlungsarten.
- Steuerrelevante Ausgaben: Posten mit dem Schlagwort „Steuer“ (etwa Handwerkerleistungen, Arbeitsmittel, Spenden) als Jahresliste mit Belegen für die Steuererklärung.

Export:

- CSV für Excel und Numbers (Semikolon als Trenner, Dezimalkomma), gefiltert nach Zeitraum und Kategorie.
- PDF-Bericht für einen Zeitraum mit Diagrammen und auf Wunsch mit Belegbildern.
- Vollständiges Backup als Datei mit allen Daten und Belegen, inklusive Wiederherstellung.

### Sicherheit und Datenschutz

- Alle Daten liegen im Speicher der App auf dem iPhone und sind durch den iOS-Datenschutz verschlüsselt.
- Optionale App-Sperre mit Face ID oder Gerätecode.
- Die App baut keine Netzwerkverbindungen auf. Einzige spätere Ausnahme ist eine iCloud-Synchronisierung, wenn sie ausdrücklich eingeschaltet wird.
- Die Daten sind im normalen iPhone-Backup (iCloud oder Mac/PC) enthalten. Zusätzlich gibt es den manuellen Export in die Dateien-App.

## Bedienkonzept

Die App hat eine Tab-Leiste mit fünf Bereichen:

| Bereich                          | Inhalt                                                                                                  |
|----------------------------------|---------------------------------------------------------------------------------------------------------|
| Übersicht                        | Monatssumme, Prognose, Budgets, letzte Buchungen                                                        |
| Ausgaben                         | Liste nach Tagen gruppiert, Suche, Filter nach Zeitraum, Kategorie, Händler, Zahlungsart und Schlagwort |
| Erfassen (mittig, hervorgehoben) | Auswahl zwischen „Beleg scannen“ und „Manuell erfassen“, langes Drücken öffnet direkt den Scanner       |
| Statistik                        | Diagramme und Kennzahlen, Zeitraumwahl am oberen Rand                                                   |
| Einstellungen                    | Kategorien, Budgets, Fixkosten, Export und Backup, App-Sperre                                           |

Ablauf eines Beleg-Scans:

1.  Scanner öffnen und den Beleg fotografieren. Die Kante wird automatisch erkannt.
2.  Die Texterkennung läuft auf dem Gerät und dauert etwa eine Sekunde.
3.  Die Prüfmaske zeigt Betrag, Firma, Datum und die vorgeschlagene Kategorie.
4.  Werte prüfen, bei Bedarf korrigieren, Beschreibung ergänzen und speichern.

## Ausbaustufen

| Stufe                     | Inhalt                                                                                                                        | Ergebnis                                 |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------|------------------------------------------|
| 0: Grundlage              | Repository-Struktur, Swift-Paket mit Kernlogik, Tests, automatische Prüfung bei jedem Push                                    | Grundgerüst, das baut und getestet ist   |
| 1: MVP                    | Manuelle Erfassung, Kategorien, Ausgabenliste mit Suche, Monatsstatistik nach Kategorien, 12-Monats-Verlauf, CSV-Export       | App im Alltag nutzbar                    |
| 2: Belegscan              | Dokumentenscanner, Texterkennung, Erkennung von Summe, Firma und Datum, Prüfmaske, Belegbilder, Lernen der Händler-Kategorien | Kassenzettel in wenigen Sekunden erfasst |
| 3: Auswertung und Planung | Budgets, Fixkosten und Abos, Perioden- und Vorjahresvergleich, Händler-Ranking, Prognose, PDF-Bericht, Face ID, Backup        | Vollständige Haushaltsübersicht          |
| 4: Komfort                | Widgets, Siri und Kurzbefehle, PDF-Import über Teilen, KI-Auswertung auf dem Gerät, iCloud-Sync, Fremdwährungen für Reisen    | Weniger Handgriffe im Alltag             |

## Getroffene Entscheidungen

| Datum      | Entscheidung                                                                                   |
|------------|------------------------------------------------------------------------------------------------|
| 21.11.2026 | Native iPhone-App mit SwiftUI, keine Web-App.                                                  |
| 21.11.2026 | Installation mit kostenloser Apple-ID („Personal Team“), Neuinstallation alle 7 Tage, kein kostenpflichtiges Developer-Konto. Folge: kein iCloud-Sync, höchstens 3 eigene Apps auf dem iPhone. |
| 21.11.2026 | Zielgerät ist ein iPhone 16 mit iOS 26. Die App setzt iOS 26 als Mindestversion voraus. |
| 21.11.2026 | Die Standardkategorien aus der Tabelle oben werden so übernommen. |

## Offene Entscheidungen

1.  Steht ein Mac zur Verfügung? Davon hängt der Installationsweg ab (Weg A mit Mac oder Weg C ohne Mac, siehe Teil 3).
2.  Sollen Belegbilder dauerhaft gespeichert werden? Ein Kassenzettel belegt komprimiert etwa 150 bis 300 KB.
