#!/usr/bin/env bash
# Prépare l'environnement de développement MSN Manager V1.
set -euo pipefail
RACINE="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== 1. Serveur : dépendances Composer ==="
cd "$RACINE/server/api"
if command -v composer >/dev/null; then composer install; else php composer.phar install || php /home/z/tools/composer.phar install; fi

echo "=== 2. .env ==="
[ -f .env ] || { cp .env.example .env; php artisan key:generate; }
echo "→ adapter DB_* (PostgreSQL) puis : php artisan migrate --seed"

echo "=== 3. Cœur Dart : dépendances + codegen Drift ==="
cd "$RACINE/packages/core"
dart pub get
dart run build_runner build --delete-conflicting-outputs

echo "=== 4. App Android (apps/mobile) ==="
cd "$RACINE/apps/mobile"
[ -d android ] || flutter create . --platforms=android --org mg.msn --project-name msn_mobile \
  || echo "(SDK Flutter requis pour cette étape)"
python3 "$RACINE/scripts/ci/patch_android.py" 2>/dev/null || true
flutter pub get || true

echo "=== 5. App Windows (apps/desktop) — machine Windows uniquement ==="
echo "→ exécuter scripts/build_windows.ps1 sur Windows (génère windows/ puis build)."

echo "=== 6. Tests rapides ==="
cd "$RACINE/packages/core" && dart test || true
cd "$RACINE/server/api" && php artisan test || true

echo "Terminé. Voir docs/03-installation.md et docs/08-codemagic.md."
