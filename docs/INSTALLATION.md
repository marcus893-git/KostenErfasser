# KostenErfasser auf dem iPhone installieren (SideStore)

Stand: 22.11.2026. Gilt für ein iPhone 16 mit iOS 26 und eine kostenlose Apple-ID.

Die Schritte stützen sich auf die SideStore-Dokumentation und aktuelle Anleitungen aus der Community (Quellen am Ende). Die offizielle Seite docs.sidestore.io war aus der Cloud-Umgebung nicht direkt abrufbar. Vor der Einrichtung lohnt deshalb ein kurzer Blick in die aktuelle Anleitung dort, falls sich Namen oder Menüs geändert haben.

## So funktioniert es

- GitHub baut die App bei jedem Push automatisch (Workflow „iOS-App“) und stellt eine unsignierte Datei `KostenErfasser.ipa` bereit.
- SideStore ist eine App auf dem iPhone, die solche Dateien mit deiner Apple-ID signiert und installiert.
- Nur um SideStore selbst einmal zu installieren, brauchst du einen Computer (Windows, macOS oder Linux). Danach läuft alles auf dem iPhone.

## Einschränkungen der kostenlosen Apple-ID

- Die Signatur gilt 7 Tage. Danach muss die App in SideStore erneuert werden („Refresh“). Läuft die Frist ab, startet die App nicht mehr, die Daten bleiben aber erhalten. Die App deshalb nicht löschen, sondern erneuern.
- Höchstens 3 selbst installierte Apps gleichzeitig. SideStore zählt mit, KostenErfasser und SideStore belegen also 2 davon.
- Nach einem iOS-Update oder dem Zurücksetzen des iPhones kann die Kopplungsdatei ungültig werden. Dann braucht man noch einmal kurz einen Computer, um mit iloader eine neue zu erzeugen.
- SideStore braucht die Anmeldung mit einer Apple-ID. Wer seine Haupt-Apple-ID nicht in eine Drittanbieter-App eingeben möchte, legt dafür eine zweite, kostenlose Apple-ID an.

## Einmalige Einrichtung

Auf dem iPhone:

1. **LocalDevVPN** aus dem App Store installieren. SideStore braucht diese VPN-App, um sich beim Installieren und Erneuern über eine lokale Verbindung mit dem iPhone selbst zu verbinden.

Am geliehenen Computer:

2. **iloader** installieren. Unter Windows vorher iTunes installieren. 32-Bit-Windows und Windows 10 auf ARM werden nicht unterstützt.
3. Das iPhone per Kabel anschließen und auf dem iPhone „Diesem Computer vertrauen“ bestätigen.
4. In iloader mit der Apple-ID anmelden, das iPhone auswählen und **SideStore (Stable)** installieren. iloader legt dabei die Kopplungsdatei `ALTPairingFile.mobiledevicepairing` auf dem iPhone ab.

Wieder auf dem iPhone (der Computer wird danach nicht mehr gebraucht):

5. Einstellungen > Allgemein > VPN & Geräteverwaltung: der eigenen Apple-ID unter „Entwickler-App“ vertrauen.
6. Einstellungen > Datenschutz & Sicherheit > Entwicklermodus einschalten und das iPhone neu starten.
7. LocalDevVPN öffnen und verbinden.
8. SideStore öffnen. Fragt SideStore nach der Kopplungsdatei, unter „Auf meinem iPhone“ > SideStore die Datei `ALTPairingFile.mobiledevicepairing` wählen. Danach mit der Apple-ID anmelden.

## KostenErfasser installieren

1. In Safari bei GitHub anmelden und im Repository KostenErfasser auf „Actions“ > „iOS-App“ gehen. Den neuesten Lauf mit grünem Haken öffnen und unter „Artifacts“ die Datei `KostenErfasser-<Nummer>` laden. Werden die Artifacts nicht angezeigt, in Safari „Desktop-Website anfordern“ wählen.
2. In der Dateien-App die geladene ZIP-Datei antippen. Sie wird entpackt, darin liegt `KostenErfasser.ipa`.
3. LocalDevVPN verbinden, SideStore öffnen, unter „My Apps“ auf „+“ tippen und `KostenErfasser.ipa` auswählen.

Ein Update installierst du genauso. Die Daten bleiben erhalten, solange die App nicht gelöscht wird. Welche Version installiert ist, steht in der App unter Einstellungen > Info (die Zahl in Klammern ist die Nummer des GitHub-Laufs).

## Alle 7 Tage erneuern

1. WLAN einschalten und LocalDevVPN verbinden.
2. SideStore öffnen und unter „My Apps“ auf „Refresh All“ tippen.

Eine wiederkehrende Erinnerung im Kalender alle 6 Tage hilft, die Frist nicht zu verpassen. Unter iOS 26.4 und neuer wird das Erneuern im WLAN in Community-Berichten teils als unzuverlässig beschrieben. Dann hilft oft, in den WLAN-Einstellungen für das eigene Netz die „Private WLAN-Adresse“ auszuschalten.

## Wenn etwas nicht klappt

| Meldung oder Problem | Lösung |
|----------------------|--------|
| Kopplungsdatei ungültig („pairing file invalid“) | Mit einem Computer und iloader („Manage Pairing File“) eine neue Kopplungsdatei erzeugen und in SideStore auswählen. Tritt meist nach iOS-Updates auf. |
| Fehler 1006 | In den SideStore-Einstellungen die Kopplungsdatei zurücksetzen und neu auswählen. |
| Installieren oder Erneuern schlägt fehl | Ist LocalDevVPN verbunden und das WLAN an? „Private WLAN-Adresse“ für das Netz ausschalten. |
| App startet nicht mehr | Die 7 Tage sind abgelaufen. In SideStore erneuern, die Daten sind noch da. |

## Quellen

- [SideStore-Dokumentation: Voraussetzungen](https://docs.sidestore.io/docs/installation/prerequisites)
- [iloader Guide 2026 (Scarlet iOS)](https://scarletios.com/iloader-guide/)
- [SideStore Errors Explained (Scarlet iOS)](https://scarletios.com/sidestore-errors-explained/)
- [SideStore-Installation mit iloader (GitHub, Slade-Bennett)](https://github.com/Slade-Bennett/sidestore-installation-guide)
- [Zusammenfassung der SideStore-Installation (GIGAZINE, Juni 2026)](https://gigazine.net/gsc_news/en/20260628-sidestore-sideloading-ios/)
- [SideStore und LiveContainer unter iOS 26 (iPhoneSoft, März 2026)](https://iphonesoft.fr/2026/03/11/guide-ios-26-installer-sidestore-livecontainer-sideloader-apps-jailbreak)
