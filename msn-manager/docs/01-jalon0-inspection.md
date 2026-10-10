# Jalon 0 — Inspection et plan (MSN Manager V1)

**Date :** 10 octobre 2026 · **Statut :** Terminé · **Prochain jalon :** Jalon 1 (monorepo) + Jalon 2 (bases de données)

---

## 1. Document de spécification

Le document `MSN_Manager_V1_Specification_Technique.md` (1 033 lignes, 12 sections + 50 scénarios
d'acceptation) a été **lu intégralement**. Il sert de référence fonctionnelle et technique. Les
exigences ont été extraites dans la matrice de la section 6 ci-dessous.

## 2. Contradictions détectées dans la spécification et résolutions retenues

| # | Point de la spec | Contradiction | Résolution retenue (la plus sûre) |
|---|------------------|---------------|-----------------------------------|
| C1 | §4.1 « `commandes 1—N devis` » vs §5 `UNIQUE(commande_id)` sur `devis` | Le schéma SQL interdit plusieurs devis liés à une commande, alors que les relations annoncent un historique | `commande_id` devient une **FK simple indexée** (pas UNIQUE). La règle « une seule version courante proposée à la fois » est une **règle métier** (statuts `presente`/`modification_demandee` uniques par demande), vérifiée par le domaine et le serveur, pas par une contrainte SQL. Documentée dans la migration. |
| C2 | §5 `demande_prestations UNIQUE(demande_id, service_id)` | Bloque plusieurs lots du même service dans une demande | **Conservée** pour la V1 (comme le suggère §5.1) : plusieurs lots du même service sont représentés dans `details_json`. Migration dédiée possible plus tard. |
| C3 | §5 `quantite NUMERIC` en SQLite | SQLite n'a pas de NUMERIC exact | Stockage **TEXT décimal canonique** en SQLite ; conversion via un type `Decimal` du domaine (entiers scaled). PostgreSQL garde `NUMERIC(12,3)`. Jamais de `double`. |
| C4 | §7.2 `POST /commandes` vs règle « commande créée à l'acceptation du devis » | Deux voies de création de commande | `POST /devis/{id}/accept` avec `creer_commande: true` est **la voie canonique** (transactionnelle + idempotente). `POST /commandes` reste disponible pour l'« exception explicitement documentée » (règle métier 6) et exige `devis_accepte_id` + clé d'idempotence. |
| C5 | §5 `appareils` présent dans le schéma local SQLite **et** côté serveur | Double autorité | Table locale = **copie locale en lecture** alimentée par `POST /devices/register` (jamais poussée par l'outbox métier) ; le serveur est autoritaire. |
| C6 | Statuts facture `partiellement_payee`/`payee` stockés mais « calculés » | Risque d'incohérence | Ces statuts sont **recalculés et écrits uniquement par le service Paiements** dans la même transaction qu'un paiement confirmé ; aucun endpoint ne permet de les écrire directement. |
| C7 | Périmètre module 13 « Planning Facebook » mais aucune table dans la spec | Table manquante | Ajout justifié d'une table `publications_facebook` (planification, contenu, statut `planifie|prete|publie_manuellement|annule`, canal) — préparation et suivi uniquement, **aucune publication automatique**. |
| C8 | §8.4 pull « curseur monotone » mais aucune table serveur de séquence globale | Mécanisme non réalisable sans support | Ajout justifié d'une table serveur `sync_journal` (séquence globale monotone, one row per committed change) alimentée dans les mêmes transactions que les écritures métier. |

## 3. Inspection de l'environnement

| Outil requis | Disponible ? | Détail / mise en place |
|---|---|---|
| Flutter / Dart | ❌ / ✅ (installé) | Flutter absent au départ ; **Dart SDK stable téléchargé** et installé dans `/home/z/tools/dart-sdk`. Le code UI Flutter est écrit et analysable avec un SDK Flutter ; le paquet `core` est **Dart pur** et ses tests s'exécutent ici. |
| PHP | ❌ → ✅ | **PHP 8.4.24 CLI portable** assemblé depuis les paquets Debian (sans root) avec pdo_sqlite, pdo_pgsql, pgsql, mbstring, intl, zip, dom, curl, bcmath. |
| Composer | ❌ → ✅ | Composer 2.10.3 (phar officiel). |
| PostgreSQL | ❌ → ✅ | **pgserver** (binaires PostgreSQL embarqués, exécutés sans root) — serveur central réel pour les migrations et tests. |
| SQLite | ✅ (lib) | `libsqlite3.so` présente ; utilisée par Drift (tests Dart) et PDO (tests Laravel rapides). |
| Android SDK / Windows | ❌ | **Compilation APK/EXE impossible dans cet environnement** (Linux sans Android SDK, pas de toolchain MSVC). Scripts de build fournis (`scripts/build_apk.sh`, `scripts/build_windows.ps1`) — à exécuter sur une machine de développement. Conformément à vos règles, **aucun APK n'est déclaré produit**. |
| Docker | ❌ | Non requis ; pgserver remplace un serveur PG de test. |

Ressources : 2 vCPU, 4,1 Go RAM, ~9,3 Go disque. Réseau : OK (deb.debian.org, pub.dev, getcomposer.org).

## 4. Structure du projet (monorepo)

```
msn-manager/
├── apps/mobile_desktop/     # Application Flutter (Android + Windows), UI française
│   └── lib/                 # UI + état (Riverpod) ; délègue tout au paquet core
├── packages/core/           # Dart PUR : domaine, règles, Drift/SQLite, outbox, moteur de sync
│   └── (testable sans Flutter → `dart test` exécutable dans cet environnement)
├── server/api/              # API Laravel (REST /api/v1), PostgreSQL, règles métier autoritaires
├── docs/                    # Documentation (architecture, installation, sync, sécurité, tests, dépannage)
├── scripts/                 # setup, lancement, builds, sauvegardes
└── README.md
```

**Choix d'architecture clé :** le paquet `packages/core` est **Dart pur** (aucune dépendance Flutter).
Il contient les entités, les machines à états, les repositories Drift, l'outbox et le moteur de
synchronisation. L'application Flutter n'est qu'une couche présentation au-dessus. Ceci garantit la
séparation stricte exigée (interface / domaine / repositories / stockage / synchronisation) et rend
le cœur **réellement testable dans cet environnement** via `dart test`.

## 5. Blocages réels (pas des suppositions)

1. **Pas de compilation Flutter** dans cet environnement (pas de SDK Flutter/Android au départ ;
   SDK Dart seul installé). Conséquence : UI Flutter non compilée ici — code écrit, analyse statique
   et tests exécutés au niveau du paquet `core` (Dart pur). Aucun APK ni EXE n'est produit ni prétendu.
2. **Pas de PostgreSQL système** → remplacé par pgserver embarqué pour les tests réels.
3. Pas de compte Messenger/WhatsApp/Facebook ni de service d'e-mail → **aucune intégration
   d'envoi automatique n'est implémentée ni prétendue** ; l'app prépare le texte, permet la copie et
   exige la confirmation manuelle (conforme à la spec).

## 6. Matrice exigences → modules → tests (extrait, version complète dans docs/06-tests.md)

| Exigence (source) | Module serveur | Module client | Test exécuté |
|---|---|---|---|
| Migrations sur base vide (§6, §11.1) | `database/migrations/*` | `packages/core` Drift v1→n | `php artisan migrate` sur PG vide + `dart test` migration |
| CRUD client/contact (§7.2) | ClientController, ContactController | Repositories core | Feature test S-A1..A3 |
| Détection doublons (§10.3) | ClientService::findDuplicates | écran clients | Feature test A3 |
| Demande sans commande (§1 règle 1, §10.5) | DemandeService | écran demandes | Feature test A4-A6 |
| Message : infos manquantes seulement (§6.C) | MessageService::prepare | écran messages | Feature test E28-E31 |
| 60 × 1 500 = 90 000 (§10.10) | PrixService | domaine core | Feature test B10 + test Dart |
| Tarif modifié ≠ anciens devis (§10.9) | instantanés lignes | lignes snapshot | Feature test B9 |
| Devis présenté/modifié/accepté/refusé (§10.11-13) | DevisService (révisions) | écran devis | Feature tests B11-B13 |
| Commande atomique idempotente (§6.F, §10.16) | AcceptationService | écran devis→commande | Feature tests C15-C16 |
| Plusieurs projets/commande (§10.17) | ProjetController | écran projets | Feature test C17 |
| Transitions invalides refusées (§10.18) | Machine à états | domaine core | Feature test C18 + test Dart |
| Livraison avant « livrée » (§10.19) | LivraisonService | écran commande | Feature test C19 |
| Solde facture/paiements (§10.21-24) | PaiementService | écran finances | Feature tests D21-D24 |
| Idempotence paiement (§10.25) | idempotency_key | outbox | Feature test D25 |
| Préparé/copié ≠ envoyé (§10.28-31) | CommunicationService | écran messages | Feature tests E28-E31 |
| Push idempotent, reprise, conflits (§8, §10.37-43) | SyncController | moteur sync core | Feature tests F + tests Dart |
| Fichier SHA-256 (§8, §10.41) | AttachmentController | gestion fichiers | Feature test F41 |
| Auth 401/403/422, révocation (§10.44-48) | AuthController, middleware | client HTTP | Feature tests G44-G48 |

## 7. Décisions techniques signalées (hypothèses justifiées)

1. **Laravel 12 + PHP 8.4** : versions stables actuelles, compatibles l'environnement assemblé.
2. **PostgreSQL 17 via pgserver** pour les tests serveur réels ; SQLite pour la suite rapide.
3. **Jetons** : Laravel Sanctum (jetons d'accès personnels + révocation) adapté au modèle
   « un utilisateur, N appareils » ; renouvellement géré par jeton longue durée dédié au refresh.
4. **Numérotation** DEV-AAAA-NNNN / CMD-AAAA-NNNN / FAC-AAAA-NNNN : table serveur `sequences`
   incrémentée atomiquement dans la transaction (aucune collision).
5. **Montants** : entiers (Ariary sans centimes). **Quantités** : `Decimal` exact côté Dart.
6. **Ulid/UUID v4** générés côté client et côté serveur, jamais d'auto-incrément exposé.
