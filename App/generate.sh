#!/bin/bash
# Erzeugt das Xcode-Projekt aus project.yml und öffnet es (auf dem Mac).
#
# Team und Bundle-ID, die in Xcode unter „Signing & Capabilities“ gewählt wurden,
# sichert das Skript vorher in Signing.local.xcconfig. So bleiben sie erhalten,
# wenn das Projekt neu erzeugt wird. Mit NO_OPEN=1 wird Xcode nicht geöffnet.
set -euo pipefail
cd "$(dirname "$0")"

PROJECT_FILE="KostenErfasser.xcodeproj/project.pbxproj"
LOCAL_CONFIG="Signing.local.xcconfig"

save_signing() {
    [ -f "$PROJECT_FILE" ] || return 0
    local team bundle
    team=$(sed -nE 's/.*DEVELOPMENT_TEAM = "?([A-Z0-9]{10})"?;.*/\1/p' "$PROJECT_FILE" | head -n 1 || true)
    bundle=$(sed -nE 's/.*PRODUCT_BUNDLE_IDENTIFIER = "?([A-Za-z0-9.-]+)"?;.*/\1/p' "$PROJECT_FILE" | head -n 1 || true)
    [ -n "$team" ] || [ -n "$bundle" ] || return 0

    # Bereits gesicherte Werte behalten, wenn das Projekt keinen neuen Wert enthält.
    if [ -f "$LOCAL_CONFIG" ]; then
        [ -n "$team" ] || team=$(sed -nE 's/^DEVELOPMENT_TEAM = ([A-Z0-9]{10})$/\1/p' "$LOCAL_CONFIG" | head -n 1 || true)
        [ -n "$bundle" ] || bundle=$(sed -nE 's/^PRODUCT_BUNDLE_IDENTIFIER = ([A-Za-z0-9.-]+)$/\1/p' "$LOCAL_CONFIG" | head -n 1 || true)
    fi

    {
        echo "// Lokale Signatur-Einstellungen, geschrieben von generate.sh. Nicht einchecken."
        if [ -n "$team" ]; then echo "DEVELOPMENT_TEAM = $team"; fi
        if [ -n "$bundle" ]; then echo "PRODUCT_BUNDLE_IDENTIFIER = $bundle"; fi
    } > "$LOCAL_CONFIG"
    echo "Signatur gesichert in App/$LOCAL_CONFIG (Team: ${team:-keins}, Bundle-ID: ${bundle:-Standard})"
}

save_signing

if ! command -v xcodegen > /dev/null 2>&1; then
    echo "XcodeGen fehlt. Installieren mit: brew install xcodegen" >&2
    exit 1
fi
xcodegen generate --spec project.yml

if [ "$(uname)" = "Darwin" ] && [ "${NO_OPEN:-0}" != "1" ]; then
    open KostenErfasser.xcodeproj
fi
