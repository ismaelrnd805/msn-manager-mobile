# Installation et démarrage

## Prérequis

| Composant | Version | Rôle |
|---|---|---|
| PHP | ≥ 8.2 (testé 8.4) | API Laravel |
| Composer | 2.x | dépendances serveur |
| PostgreSQL | ≥ 15 (testé 16.2) | base centrale |
| Flutter | ≥ 3.24 | application Android + Windows |
| Android SDK + JDK 17 | — | compilation APK (machine de build) |
| Visual Studio 2022 « Desktop development with C++ » | — | compilation Windows |

## 1. Serveur (Laravel + PostgreSQL)

```bash
cd server/api
cp .env.example .env
php composer.phar install        # ou composer install
php artisan key:generate

# Adapter dans .env :
#   DB_CONNECTION=pgsql, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD
#   APP_URL=https://votre-serveur.mg

php artisan migrate --seed       # tables + catalogue initial (8 services)
php artisan serve                # http://127.0.0.1:8000
```

Identifiants par défaut (SEED de développement — changer immédiatement) :
`admin@msn.mg` / `change-moi-2026`.

Tests serveur : `php artisan test` (configurer `.env.testing` ou variable `DB_CONNECTION=sqlite DB_DATABASE=:memory:`).

## 2. Application Android (apps/mobile)

`android/` est déjà inclus (généré + patché, config validée par build réel) :

```bash
cd apps/mobile
flutter pub get
flutter run -d <id-appareil-android>
flutter build apk --release                    # APK : build/app/outputs/flutter-apk/
```

## 3. Application Windows (apps/desktop) — machine Windows avec VS 2022

```powershell
cd apps\desktop
flutter create . --platforms=windows --project-name msn_desktop
flutter pub get
flutter run -d windows
flutter build windows --release                # exe : build\windows\x64\runner\Release\
```

Compilation sans machine locale : CI **Codemagic** prête à l'emploi
(`codemagic.yaml`, deux workflows séparés) — voir `docs/08-codemagic.md`.

Le paquet `packages/core` (Dart pur) n'exige pas Flutter :

```bash
cd packages/core
dart pub get
dart test                       # 36 tests du cœur
```

## 4. Configuration de l'application

Écran **Paramètres** :
1. URL de l'API (ex. `https://votre-serveur.mg/api/v1`) ;
2. email + mot de passe ;
3. « Se connecter et enregistrer cet appareil » → jeton stocké en mémoire,
   appareil enregistré côté serveur, synchronisation initiale lancée.

## 5. Synchronisation inter-appareils

- Android et Windows utilisent le **même compte** (`admin@msn.mg`) ;
- chaque appareil a un `device_id` UUID propre ;
- les modifications hors ligne partent vers le serveur (push) et reviennent
  vers l'autre appareil (pull) — voir `docs/04-synchronisation.md`.

## 6. Production

- **HTTPS obligatoire** (reverse proxy nginx/Caddy recommandé) ;
- changer le mot de passe du compte par défaut ;
- sauvegardes automatiques PostgreSQL — voir `docs/05-securite.md` ;
- `php artisan config:cache route:cache` après déploiement.
