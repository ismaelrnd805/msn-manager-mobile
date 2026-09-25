# MSN Manager Mobile

Application métier **offline-first** pour **MSN — Multi-Services Numériques** :
gérer toute l'activité depuis un téléphone — demandes, qualification, devis,
factures, paiements, workflows, communication client (messages/images/PDF) et
transfert des commandes vers le PC de production.

> Le téléphone est le premier outil de travail. L'application ne fait pas que
> rappeler ce qu'il faut faire : **elle prépare le travail** (messages prêts à
> copier, visuels et PDF prêts à partager, étapes pré-remplies).

---

## Sommaire

1. [Fonctionnalités](#1-fonctionnalités)
2. [Stack technique](#2-stack-technique)
3. [Installation et lancement](#3-installation-et-lancement)
4. [Architecture](#4-architecture)
5. [Base de données et migrations](#5-base-de-données-et-migrations)
6. [Fonctionnement offline](#6-fonctionnement-offline)
7. [Synchronisation (transfert PC)](#7-synchronisation-transfert-pc)
8. [Configuration](#8-configuration)
9. [Génération Android (APK)](#9-génération-android-apk)
10. [Recettes d'extension](#10-recettes-dextension)
11. [Comptes de démonstration](#11-comptes-de-démonstration)
12. [Cycle métier complet](#12-cycle-métier-complet)

---

## 1. Fonctionnalités

| Domaine | Contenu |
|---|---|
| Demandes | Enregistrement des demandes reçues (Messenger, WhatsApp, appel, SMS, présentiel), référence automatique `REQ-2026-0001`, priorités, fichiers joints |
| Qualification | Formulaires dynamiques **par service** (logo, mémoire, affiche…), modifiables par l'administrateur sans toucher au code |
| Catalogue | Services, catégories, tarifs (Ariary), délais, inclus/exclusions — présentable en **message / image / PDF** |
| Devis | Lignes pré-remplies depuis le catalogue, calcul automatique (réduction, acompte, solde), conversion `DEMANDE → DEVIS → COMMANDE` sans ressaisie |
| Factures & paiements | Factures depuis commandes/devis, acomptes et soldes (espèces, MVola, Orange Money, Airtel Money, virement), statuts automatiques |
| Commandes & workflows | Machine à étapes par service (« Où suis-je ? Que dois-je faire ? Quelle action est prête ? »), règles métier bloquantes + **EXCEPTION AUTORISÉE** |
| Transfert PC | Checklist des 9 vérifications obligatoires puis `TRANSFÉRER AU PC` |
| Communication | 14 catégories de modèles avec variables `{{PRENOM}}`, `{{MONTANT}}`… remplacées automatiquement |
| Documents | PDF professionnels (devis, factures, fiches, catalogue) + images PNG rastérisées, partage natif |
| Rappels & tâches | Deadlines, relances, acomptes, soldes — notifications locales |
| Administration | Modules activables, modèles de messages, questions de qualification, règles, utilisateurs/PIN, journal d'activité, corbeille, sauvegarde JSON |

## 2. Stack technique

- **Flutter / Dart** (Flutter ≥ 3.22, Dart ≥ 3.4) — UI 100 % française, optimisée petits écrans Android
- **Riverpod 2** — state management (providers par domaine, zéro singleton global)
- **Drift (SQLite)** — base locale complète (28 tables), migrations versionnées
- **go_router** — navigation 5 onglets + routes de détail
- **pdf + printing** — génération PDF professionnelle et rasterisation PNG (format image)
- **share_plus** — partage natif (texte, image, PDF) vers Messenger/WhatsApp/email
- **connectivity_plus** — détection ONLINE/OFFLINE
- **flutter_local_notifications** — rappels locaux (architecture compatible FCM)
- **crypto** — hachage PIN (SHA-256 salé) ; **file_picker** — réception de fichiers

## 3. Installation et lancement

Prérequis : Flutter SDK ≥ 3.22 (`flutter doctor` OK), Android SDK.

```bash
# 1. Décompresser le projet puis :
cd msn-manager-mobile

# 2. Générer les dossiers plateforme (android/) — non inclus dans l'archive :
flutter create --org mg.msn --project-name msn_manager_mobile --platforms android .

# 3. Dépendances :
flutter pub get

# 4. Générer le code Drift (base de données) :
dart run build_runner build --delete-conflicting-outputs

# 5. Lancer (appareil ou émulateur) :
flutter run
```

Tests de la logique métier (calculs, templates, workflow, règles, checklist) :

```bash
flutter test
```

Au **premier lancement**, la base est créée (schéma v3) et remplie avec des
**données de démonstration** (clients, services, workflows, devis, commande en
production, facture partiellement payée, paiements, rappels…). Aucune donnée
réelle n'est utilisée.

## 4. Architecture

```
lib/
├── main.dart / app.dart            # point d'entrée, démarrage contrôlé
├── core/
│   ├── constants/                  # constantes, clés de règles métier
│   ├── theme/                      # palette MSN (#0B4FA8 / #00B8D4), Material 3
│   ├── router/                     # go_router (5 onglets + gardes de session)
│   ├── utils/                      # formatters (Ariary, dates), id_generator, validators
│   ├── errors/                     # exceptions typées (règles, permissions, réseau)
│   ├── domain/                     # LOGIQUE MÉTIER PURE (testée) :
│   │   ├── quote_calculator.dart   #   calculs devis/factures
│   │   ├── template_engine.dart    #   moteur de modèles {{VARIABLES}}
│   │   ├── workflow_engine.dart    #   progression + catalogue d'actions
│   │   ├── business_rules.dart     #   règles bloquantes + exceptions
│   │   └── transfer_checklist.dart #   les 9 vérifications transfert PC
│   ├── database/                   # Drift : 28 tables + DAOs + migrations + seed démo
│   ├── auth/                       # session, rôles, permissions
│   ├── modules/                    # registre des modules activables
│   ├── services/                   # numbering, activity, pdf, share, notifications,
│   │                               # backup, reminder, file_ingest, connectivity
│   ├── sync/                       # file d'attente, moteur push/pull, conflits, API /api/v1
│   └── providers/                  # wiring Riverpod (DB, DAOs, services)
├── features/                       # UN DOSSIER PAR MODULE (indépendants)
│   ├── dashboard/ clients/ requests/ catalog/ quotes/ invoices/
│   ├── payments/ orders/ communication/ documents/ tasks/ sync/
│   ├── settings/ more/ shell/ splash/ auth/
└── shared/widgets/                 # composants réutilisables (badges, cartes,
                                    # CopyMessageCard, champs de formulaire…)
```

Principes : `core/` ne dépend jamais de `features/` ; chaque feature expose ses
providers ; la logique métier réside dans `core/domain/` (100 % testable) ; les
DAOs sont la seule porte d'entrée vers SQLite. Détail complet :
[docs/01-architecture.md](docs/01-architecture.md).

## 5. Base de données et migrations

- Schéma : `lib/core/database/tables.dart` (28 tables) — référence complète dans
  [database/schema.md](database/schema.md).
- Version actuelle : **3** (`schemaVersion` dans `app_database.dart`).
- Colonnes transverses offline : `lastSyncedAt` (sync), `deletedAt` (corbeille).
- Compteurs de numérotation annuels stockés dans `settings` (REQ/DEV/CMD/FAC/PMT).

**Créer une migration (règle absolue : ne jamais modifier le schéma sans
migration)** — exemple v3 → v4 :

```dart
// 1. tables.dart : ajouter la colonne
TextColumn get satisfactionNote => text().nullable()();

// 2. app_database.dart : incrémenter la version et ajouter le bloc
@override
int get schemaVersion => 4;
// dans migration.onUpgrade :
if (from < 4) {
  await m.addColumn(clients, clients.satisfactionNote);
}
```

Tutoriel détaillé : [docs/02-donnees-et-migrations.md](docs/02-donnees-et-migrations.md)
et [database/migrations.md](database/migrations.md).

## 6. Fonctionnement offline

L'application est **100 % fonctionnelle sans Internet** : base locale, PDF,
images, partage, rappels, journal. Aucun écran ne dépend d'un appel réseau.
L'état est visible en permanence (`OFFLINE`, `ONLINE`, `SYNCHRONISATION EN
COURS`, `SYNCHRONISÉ`, `ERREUR DE SYNCHRONISATION`). Détails :
[docs/03-offline-first.md](docs/03-offline-first.md).

## 7. Synchronisation (transfert PC)

Chaque écriture locale est mise en file (`sync_queue`). Dès qu'une connexion
et un serveur sont disponibles : **PUSH** des changements par lots
(`POST /api/v1/sync/batch`), **PULL** des changements serveur
(`GET /api/v1/sync/changes`). Une donnée modifiée des deux côtés n'est
**jamais écrasée** : un conflit est enregistré et présenté à un humain
(garder local / garder distant). Sans serveur configuré, rien ne quitte le
téléphone. Spécification serveur NestJS + PostgreSQL :
[docs/05-backend-nestjs.md](docs/05-backend-nestjs.md) ; moteur :
[docs/04-synchronisation.md](docs/04-synchronisation.md).

## 8. Configuration

Dans l'app (Administration) :

- **Modules** : activer/désactiver chaque domaine (effet immédiat) ;
- **Serveur de synchronisation** : URL du backend (écran Synchronisation) ;
- **Modèles de messages / questions de qualification / règles métier** :
  éditables sans code ;
- **Utilisateurs & PIN**, **journal d'activité**, **corbeille**,
  **sauvegarde/export JSON**.

## 9. Génération Android (APK)

```bash
flutter build apk --release
# APK : build/app/outputs/flutter-apk/app-release.apk
```

Le manifeste doit déclarer notifications et alarms exactes — XML prêt à
copier et procédure complète (signature, installation adb) :
[docs/10-generer-android.md](docs/10-generer-android.md).

## 10. Recettes d'extension

| Objectif | Procédure |
|---|---|
| Ajouter un **module** | Entrée dans `ModuleCatalog` + écran + route — [docs/06-ajouter-module.md](docs/06-ajouter-module.md) |
| Ajouter un **service/tarif** | Depuis l'app (Catalogue → +) — [docs/07-ajouter-service-workflow.md](docs/07-ajouter-service-workflow.md) |
| Ajouter un **workflow** | Modèle + étapes + codes d'actions (`ActionCatalog`) — [docs/07-ajouter-service-workflow.md](docs/07-ajouter-service-workflow.md) |
| Ajouter un **modèle de message** | Depuis l'app (Administration → Modèles) avec variables — [docs/08-modeles-messages.md](docs/08-modeles-messages.md) |
| Ajouter un **format de présentation** | S'appuyer sur `core/services/pdf/` (PDF → PNG → partage) — [docs/09-formats-presentation.md](docs/09-formats-presentation.md) |

## 11. Comptes de démonstration

| Utilisateur | PIN | Rôle |
|---|---|---|
| Admin | 1234 | Administrateur (modules, tarifs, utilisateurs, exceptions, corbeille) |
| Faniry | 1111 | Opérateur (demandes, devis, commandes, paiements) |

**Changez ces PIN immédiatement en production** (Administration → Utilisateurs).

## 12. Cycle métier complet

```
CLIENT → DEMANDE → QUALIFICATION → COMMUNICATION → SERVICE → TARIF
   → MESSAGE / IMAGE / PDF → DEVIS → CONDITIONS → ACOMPTE → COMMANDE
   → WORKFLOW → SUIVI → RAPPELS → TRANSFERT PC → PRODUCTION
   → VALIDATION → LIVRAISON → FACTURE → PAIEMENT → ARCHIVAGE
```

Chaque brique est conçue pour évoluer (MSN Manager Desktop, Messenger,
WhatsApp Business, email, paiements en ligne, IA, statistiques) **sans rien
refaire** — voir [docs/12-feuille-de-route.md](docs/12-feuille-de-route.md).
