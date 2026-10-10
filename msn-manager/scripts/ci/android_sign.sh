#!/usr/bin/env bash
# CI Codemagic — signature de production de l'APK si un keystore est fourni.
# Sans keystore : l'APK release reste signé debug (installable, tests internes).
#
# Variables attendues (groupe Codemagic `msn_android_signing`) :
#   CM_KEYSTORE_PATH       — chemin du keystore téléversé dans Codemagic
#   CM_KEYSTORE_PASSWORD   — mot de passe du keystore
#   CM_KEY_ALIAS           — alias de la clé (défaut : msn)
#   CM_KEY_ALIAS_PASSWORD  — mot de passe de la clé (défaut : = keystore)
set -euo pipefail

APK_DIR="$(cd "$(dirname "$0")/../.." && pwd)/apps/mobile/build/app/outputs/flutter-apk"
APK="$APK_DIR/app-release.apk"

if [ -z "${CM_KEYSTORE_PATH:-}" ]; then
  echo "→ Aucun keystore fourni : APK signé debug conservé (tests internes)."
  exit 0
fi
if [ ! -f "$APK" ]; then
  echo "!! APK introuvable : $APK" >&2
  exit 1
fi

# Derniers build-tools disponibles sur la machine CI
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
BT="$(ls -d "$SDK/build-tools/"* | sort -V | tail -1)"
echo "→ build-tools : $BT"

"$BT/zipalign" -f 4 "$APK" "$APK_DIR/app-release-aligned.apk"
"$BT/apksigner" sign \
  --ks "$CM_KEYSTORE_PATH" \
  --ks-key-alias "${CM_KEY_ALIAS:-msn}" \
  --ks-pass "pass:$CM_KEYSTORE_PASSWORD" \
  --key-pass "pass:${CM_KEY_ALIAS_PASSWORD:-${CM_KEYSTORE_PASSWORD}}" \
  --out "$APK_DIR/app-release-signed.apk" \
  "$APK_DIR/app-release-aligned.apk"
"$BT/apksigner" verify "$APK_DIR/app-release-signed.apk"

mv "$APK_DIR/app-release-signed.apk" "$APK"
rm -f "$APK_DIR/app-release-aligned.apk"
echo "OK APK signé production : $APK"
