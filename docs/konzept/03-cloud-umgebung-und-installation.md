# KostenErfasser: Cloud-Umgebung, Entwicklung und Installation

Stand: 21.11.2026 (Fassung im Repository; das Original liegt in Google Drive unter Claude/KostenErfasser). Teil 3 von 3.

## Was in der Cloud-Umgebung möglich ist

Die Cloud-Sessions von Claude Code laufen in einem Linux-Container (Ubuntu 24.04). Dort wird das Swift-Paket mit der Fachlogik gebaut, getestet und formatiert. Die iOS-App selbst braucht für Build, Simulator und Signierung Xcode und damit einen Mac.

| Aufgabe                                                  | Cloud (Linux)               | Mac mit Xcode |
|----------------------------------------------------------|-----------------------------|---------------|
| Fachlogik schreiben und testen (swift build, swift test) | ja                          | ja            |
| Code formatieren (swift format)                          | ja                          | ja            |
| SwiftUI-Code schreiben                                   | ja, aber nicht kompilierbar | ja            |
| App bauen, Simulator, SwiftUI-Vorschau                   | nein                        | ja            |
| Signieren und auf dem iPhone installieren                | nein                        | ja            |

## Umgebung „KostenErfasser“

Eine eigene, persönliche Umgebung, angelegt am 21.11.2026 und mit dem Repository marcus893-git/KostenErfasser verknüpft. Die Default-Umgebung bleibt unverändert und gilt weiter für alle anderen Repositories.

### Netzwerk

| Freigabe                                  | Grund                                                                                            |
|-------------------------------------------|--------------------------------------------------------------------------------------------------|
| Paketquellen (apt, npm, PyPI und weitere) | Standard, wird für die Systempakete der Swift-Toolchain gebraucht                                |
| MCP-Server                                | Standard, für Connectors wie Google Drive                                                        |
| download.swift.org                        | Download der Swift-Toolchain für Linux. Ohne diese Freigabe wurde der Abruf vom Proxy blockiert. |

GitHub ist über den Git-Proxy der Session erreichbar, Swift-Pakete von GitHub lassen sich damit auflösen. www.swift.org, von wo das Skript die Signaturschlüssel lädt, war bereits erreichbar.

### Setup-Skript

Das Skript läuft bei jedem frisch gebauten Container als root, bevor Claude startet. Es installiert Swift 6.4.3 nach /opt/swift, prüft die GPG-Signatur des Downloads und legt Links nach /usr/local/bin an. Sobald das Repository eine Package.swift enthält, lädt es außerdem die Abhängigkeiten vorab. In der Session vom 21.11.2026 dauerte ein Lauf etwa 40 Sekunden. Anschließend liefen swift build, swift test (Swift Testing) und swift format erfolgreich mit einem Testpaket.

Das Skript ist in den Einstellungen der Umgebung gespeichert. Stand vom 21.11.2026:

```bash
#!/bin/bash
# KostenErfasser – Setup der Cloud-Umgebung (Ubuntu 24.04, läuft als root)
set -euo pipefail
SWIFT_VERSION=6.4.3
if ! command -v swift >/dev/null 2>&1; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq binutils git gnupg2 libc6-dev \
    libcurl4-openssl-dev libedit2 libgcc-13-dev libncurses-dev libpython3-dev libsqlite3-0 \
    libstdc++-13-dev libxml2-dev libz3-dev pkg-config tzdata unzip zlib1g-dev
  BASE="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2404/swift-${SWIFT_VERSION}-RELEASE"
  FILE="swift-${SWIFT_VERSION}-RELEASE-ubuntu24.04.tar.gz"
  TMP="$(mktemp -d)"
  curl -fsSL -o "$TMP/$FILE" "$BASE/$FILE"
  curl -fsSL -o "$TMP/$FILE.sig" "$BASE/$FILE.sig"
  export GNUPGHOME="$TMP/gnupg"; mkdir -m 700 "$GNUPGHOME"
  curl -fsSL --compressed https://www.swift.org/keys/all-keys.asc | gpg --batch --quiet --import
  gpg --batch --verify "$TMP/$FILE.sig" "$TMP/$FILE"
  mkdir -p /opt/swift
  tar -xzf "$TMP/$FILE" -C /opt/swift --strip-components=1
  rm -rf "$TMP"
  for b in swift swiftc swift-format sourcekit-lsp; do ln -sf "/opt/swift/usr/bin/$b" /usr/local/bin/; done
fi
swift --version
# Abhängigkeiten des Swift-Pakets vorab laden, sobald es im Repo existiert
if [ -f KostenErfasser/Package.swift ]; then (cd KostenErfasser && swift package resolve); fi
```

### Secrets und Variablen

Es sind keine nötig. Die App arbeitet komplett lokal, ruft keine Web-APIs auf und braucht keine API-Schlüssel. Signaturzertifikate und Provisioning-Profile von Apple gehören nicht in die Cloud-Umgebung, denn signiert wird in Xcode auf dem MacBook. Soll später GitHub Actions eine signierte App bauen, kommen Zertifikat und Profil als verschlüsselte Secrets in die Einstellungen des GitHub-Repositorys, nicht in diese Umgebung.

### Pflege

- Neue Swift-Version: SWIFT_VERSION im Skript anpassen. Das geht über das Umgebungsmenü in der Titelleiste einer Session und dann „Bearbeiten“.
- Das Skript läuft nur, wenn ein Container neu gebaut wird, nicht beim Fortsetzen einer Session.
- Soll später SwiftLint dazukommen, braucht dessen Download zusätzlich die Release-Hosts von GitHub. swift-format ist in der Toolchain enthalten und reicht zunächst.

## Entwicklungsablauf

1.  Claude arbeitet in einer Cloud-Session auf einem eigenen Branch: Fachlogik mit Tests, SwiftUI-Code und Dokumentation. Vor jedem Push muss swift test erfolgreich sein.
2.  Nach dem Push prüft GitHub Actions Formatierung und Tests unter Linux und baut auf macOS die App als Kontrolle.
3.  Auf dem MacBook den neuen Stand holen (`git pull`), `./App/generate.sh` ausführen und die App mit Xcode auf das iPhone spielen (siehe `docs/INSTALLATION.md`).
4.  Rückmeldungen aus dem Test gehen als neue Aufgabe an eine Cloud-Session.

## Installation auf dem iPhone ohne App Store

### Weg A: Mac mit Xcode und kostenloser Apple-ID

Gewählt am 22.11.2026, da ein MacBook dauerhaft verfügbar ist. Die ausführliche Anleitung mit `App/generate.sh` steht in `docs/INSTALLATION.md`.

1.  Xcode aus dem Mac App Store installieren und öffnen. Unter Xcode, Settings, Accounts die eigene Apple-ID hinzufügen.
2.  Projekt öffnen, beim Target KostenErfasser unter „Signing & Capabilities“ das „Personal Team“ wählen und eine eindeutige Bundle-ID setzen, z. B. de.deinname.kostenerfasser.
3.  iPhone per Kabel verbinden und dem Mac vertrauen. Auf dem iPhone den Entwicklermodus einschalten (Einstellungen, Datenschutz & Sicherheit, Entwicklermodus) und das iPhone neu starten.
4.  In Xcode das iPhone als Ziel wählen und die App mit „Run“ starten.
5.  Beim ersten Start dem Entwickler auf dem iPhone vertrauen: Einstellungen, Allgemein, VPN & Geräteverwaltung.

Einschränkungen: Die Signatur gilt 7 Tage. Danach startet die App erst wieder, wenn sie erneut aus Xcode installiert wird. Die Daten bleiben dabei erhalten, solange die App nicht gelöscht wird. Es sind höchstens 3 eigene Apps gleichzeitig möglich, und iCloud-Sync ist mit der kostenlosen Apple-ID nicht verfügbar.

### Weg B: Apple Developer Program für 99 € pro Jahr

Ablauf wie bei Weg A, aber mit dem bezahlten Team. Eine Installation gilt dann ein Jahr. Updates gehen per TestFlight ohne Kabel, und iCloud-Sync über CloudKit wird möglich. Das lohnt sich, sobald die App täglich genutzt wird.

### Weg C: ohne Mac

1.  GitHub Actions baut auf einem macOS-Runner eine unsignierte .ipa-Datei und stellt sie als Build-Artefakt bereit.
2.  Auf einem Windows-PC oder Mac signiert und installiert Sideloadly oder AltStore die Datei mit der kostenlosen Apple-ID.
3.  Entwicklermodus und Vertrauen auf dem iPhone wie bei Weg A. Auch hier gilt die 7-Tage-Frist. AltStore kann die Verlängerung im WLAN automatisch erledigen, solange der PC läuft.

Weg C ist umständlicher und hängt von Werkzeugen anderer Anbieter ab. Er ist als Ausweichweg gedacht, falls kein Mac verfügbar ist.

### Weg D: SideStore ohne Mac (Ausweichweg)

GitHub Actions baut die App auf einem macOS-Runner als unsignierte IPA. SideStore signiert und installiert sie auf dem iPhone mit der kostenlosen Apple-ID. Ein Computer (Windows, macOS oder Linux) wird nur einmal gebraucht, um SideStore mit iloader zu installieren, und danach erst wieder, falls nach einem iOS-Update die Kopplungsdatei ungültig wird. Das Erneuern alle 7 Tage erledigt SideStore auf dem iPhone, solange WLAN und die App LocalDevVPN verbunden sind. Die Schritt-für-Schritt-Anleitung steht in `docs/INSTALLATION-SIDESTORE.md`.
