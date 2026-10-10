#!/usr/bin/env bash
# Sauvegarde PostgreSQL horodatée avec rétention 30 jours.
# À programmer en cron quotidien (ex. 02:00) : voir docs/05-securite.md
set -euo pipefail
DEST="${MSN_BACKUP_DIR:-/var/backups/msn}"
mkdir -p "$DEST"
STAMP=$(date +%F_%H%M)
PGHOST="${PGHOST:-/var/run/postgresql}" PGUSER="${PGUSER:-postgres}"

pg_dump -h "$PGHOST" -U "$PGUSER" -Fc "${PGDATABASE:-msn}" > "$DEST/msn_$STAMP.dump"
# Ou format SQL texte pour restauration pipée :
pg_dump -h "$PGHOST" -U "$PGUSER" "${PGDATABASE:-msn}" | gzip > "$DEST/msn_$STAMP.sql.gz"

# Rétention : 30 jours
find "$DEST" -name "msn_*.dump" -mtime +30 -delete
find "$DEST" -name "msn_*.sql.gz" -mtime +30 -delete

echo "Sauvegarde terminée : $DEST/msn_$STAMP.{dump,sql.gz}"
echo "Restauration testée : voir docs/05-securite.md § Test de restauration."
