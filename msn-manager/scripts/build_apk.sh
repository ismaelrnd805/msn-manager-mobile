#!/usr/bin/env bash
# Build APK Android — À EXÉCUTER SUR UNE MACHINE AVEC ANDROID SDK
# (ou via Codemagic : workflow `android-mobile`, voir codemagic.yaml).
# Ce script n'a PAS été exécuté dans l'environnement de développement
# (pas d'Android SDK) : aucun APK n'est livré ni prétendu.
set -euo pipefail
cd "$(dirname "$0")/../apps/mobile"

# 1. Génération de la plateforme Android si absente (dépôt sans android/)
[ -d android ] || flutter create . --platforms=android --org mg.msn --project-name msn_mobile

# 2. Patch manifeste (INTERNET + libellé)
python3 "$(dirname "$0")/ci/patch_android.py"

# 3. Dépendances
flutter pub get

# 4. Codegen du cœur (si besoin)
(cd ../../packages/core && dart run build_runner build --delete-conflicting-outputs)

# 5. Build release
flutter build apk --release

echo "APK : build/app/outputs/flutter-apk/app-release.apk"
echo "Signature production : scripts/ci/android_sign.sh ou CI Codemagic (docs/08-codemagic.md)."
