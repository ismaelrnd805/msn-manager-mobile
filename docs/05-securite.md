# Sécurité, sauvegardes et restauration

## Authentification

- Laravel Sanctum : jeton d'accès **court (8 h)** + jeton de renouvellement (30 j) ;
- rotation du refresh à chaque usage (l'ancien est révoqué) ;
- `POST /auth/logout` révoque la session courante (test G48) ;
- `DELETE /devices/{id}` révoque un appareil ;
- mots de passe hachés côté serveur (bcrypt via Laravel) — jamais stockés côté client ;
- limitation de débit : login 5/min/IP, sync 30/min/utilisateur, métier 240/min/utilisateur.

## Transport et secrets

- **HTTPS obligatoire** en production (reverse proxy + certificat) ;
- l'application Flutter ne contient **aucun** secret serveur : l'URL de l'API est
  configurable dans les Paramètres, le jeton vit en mémoire de session ;
- les clients n'accèdent **jamais** directement à PostgreSQL ;
- erreurs de production sans trace interne (`APP_DEBUG=false`).

## Validation

- toute entrée validée par FormRequest/`validate()` côté serveur ;
- CHECK SQL en PostgreSQL (serveur autoritaire) + validations applicatives ;
- les statuts ne sont **pas** modifiables par PATCH générique : transitions via
  actions explicites avec `expected_version` (HTTP 409 sinon).

## Journal d'audit

`journal_actions` (serveur) + journal local (client) : création, transitions,
livraison, acceptation, rectification, annulation, suppression logique,
résolution de conflit — avec acteur, appareil, motif, avant/après.

## Sauvegardes PostgreSQL

### Script automatique (cron recommandé : quotidien 02:00)

```bash
server/api/scripts/backup_server.sh   # pg_dump compressé horodaté, rétention 30 jours
```

### Test de restauration documenté (spéc. §10.47)

```bash
# 1. Créer une base de réception
createdb -h <host> -U postgres msn_restauration_test
# 2. Restaurer le dernier dump
gunzip -c /var/backups/msn/msn_YYYY-MM-DD.sql.gz | \
  psql -h <host> -U postgres -d msn_restauration_test
# 3. Vérifier
psql -d msn_restauration_test -c "SELECT count(*) FROM clients;"
psql -d msn_restauration_test -c "SELECT count(*) FROM sync_journal;"
# 4. Valider la cohérence financière : totaux factures vs paiements confirmés
psql -d msn_restauration_test -c "
  SELECT (SELECT SUM(total) FROM factures WHERE statut IN ('emise','partiellement_payee','payee')) AS facture,
         (SELECT SUM(montant) FROM paiements WHERE statut='confirme') AS encaisse;"
# 5. Renommer si validée, sinon corriger et re-tester
```

## Sauvegarde locale (appareil)

La base SQLite (`msn_manager.db`) est copiable à chaud (WAL actif). Copiez
`msn_manager.db`, `msn_manager.db-wal`, `msn_manager.db-shm` — la restauration
s'effectue en replaçant les fichiers, l'appareil rejouera son outbox en attente.

## Inventaire des points de contrôle (spéc. §10.G)

44→401 sans authentification ✓ · 45→403 accès interdit ✓ · 46→422 avec détails ✓
· 48→révocation de session ✓ · 49→aucun secret dans le binaire Flutter ✓
