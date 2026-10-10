#!/usr/bin/env bash
# Lance le serveur API (dev) — utilise PHP tel que disponible.
set -euo pipefail
cd "$(dirname "$0")/../server/api"
if command -v php >/dev/null; then
  php artisan migrate --force
  php artisan serve --host=0.0.0.0 --port=8000
else
  echo "php absent du PATH — voir docs/03-installation.md"
  exit 1
fi
