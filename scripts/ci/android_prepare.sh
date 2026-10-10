#!/usr/bin/env bash
# CI Codemagic — prépare la plateforme Android de apps/mobile.
# 1. Génère android/ via `flutter create` (absent du dépôt par design)
# 2. Applique le patch manifeste (permission INTERNET + libellé français)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/apps/mobile"

if [ ! -d android ]; then
  echo "→ flutter create (génération android/ avec le SDK de la CI)"
  flutter create . --platforms android --org mg.msn --project-name msn_mobile
fi

echo "→ flutter pub get"
flutter pub get

echo "→ patch AndroidManifest.xml (INTERNET + libellé MSN Manager)"
python3 "$ROOT/scripts/ci/patch_android.py"
