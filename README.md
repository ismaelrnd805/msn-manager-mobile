# MSN Manager V1

Application de gestion d'activité **Multi-Services Numériques (MSN)** — Antananarivo, Madagascar.
Clients Flutter **Android + Windows**, base locale **SQLite (Drift)**, serveur **Laravel + PostgreSQL**,
**synchronisation hors ligne** Android ↔ Windows via l'API centrale.

- Interface : **français** · Devise : **Ariary (MGA, entiers)** · Fuseau : Indian/Antananarivo, dates stockées UTC.

## Structure

```
msn-manager/
├── apps/mobile/           Application Flutter ANDROID (APK) — point d'entrée mince
├── apps/desktop/          Application Flutter WINDOWS (exe) — point d'entrée mince
├── packages/msn_ui/       Interface partagée : 12 écrans, shell adaptatif, providers Riverpod
├── packages/core/         Dart PUR : domaine, règles métier, Drift/SQLite, outbox, moteur de sync
├── server/api/            API REST Laravel /api/v1 — règles métier autoritaires + PostgreSQL
├── codemagic.yaml         CI/CD Codemagic : 2 workflows séparés (Android / Windows)
├── docs/                  Documentation (inspection, architecture, installation, sync, sécurité, tests, dépannage, Codemagic)
└── scripts/               setup_dev.sh, run_server.sh, build_apk.sh, build_windows.ps1, backup_server.sh, ci/
```

## Démarrage rapide (développement)

Voir `docs/03-installation.md`. Résumé :

```bash
# 1. Serveur (Laravel + PostgreSQL)
cd server/api
cp .env.example .env            # puis adapter DB_* et APP_KEY
php artisan key:generate
php artisan migrate --seed
php artisan serve               # http://127.0.0.1:8000

# 2. Tests serveur
php artisan test

# 3. Application Android (android/ déjà inclus) / Windows
cd apps/mobile
flutter pub get && flutter build apk --release
# Windows : scripts/build_windows.ps1 sur une machine Windows
# (génère windows/ puis build) — ou CI Codemagic, voir codemagic.yaml

# 4. Tests du cœur Dart (sans Flutter)
cd packages/core
dart pub get && dart test
```

## Règles non négociables (résumé)

1. Une **demande** commerciale n'est pas une commande ; elle peut rester sans commande.
2. La commande est créée **une seule fois**, de façon **atomique et idempotente**, à l'acceptation du devis.
3. Devis/factures = **instantanés de prix** ; modifier le catalogue ne modifie pas les anciens documents.
4. Montants en **entiers MGA** (jamais de flottant). Statuts financiers **calculés**.
5. Message préparé/copié ≠ envoyé ; l'envoi est **confirmé manuellement** par l'utilisateur.
6. Hors ligne : toute écriture locale crée une opération d'**outbox persistante** dans la même transaction ;
   le push/pull est idempotent, paginé, à curseur monotone ; les conflits sont **auditablement résolus**.
7. Aucun secret serveur dans l'application Flutter ; les clients n'accèdent **jamais** directement à PostgreSQL.

## Documentation

| Fichier | Contenu |
|---|---|
| docs/01-jalon0-inspection.md | Inspection, contradictions de la spec et résolutions, matrice exigences→tests |
| docs/02-architecture.md | Architecture logique, modèle de données, protocole de synchronisation |
| docs/03-installation.md | Installation serveur + client, Android, Windows |
| docs/04-synchronisation.md | Protocole push/pull, outbox, idempotence, conflits, fichiers |
| docs/05-securite.md | Auth, jetons, limitation de débit, sauvegardes, restauration |
| docs/06-tests.md | Matrice exigences→modules→tests et résultats d'exécution réels |
| docs/07-depannage.md | Problèmes connus et solutions |
