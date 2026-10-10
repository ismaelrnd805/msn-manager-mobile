# Tests — matrice et résultats réels d'exécution

**Date d'exécution :** 10 octobre 2026 · **Environnement :** Debian 13, PHP 8.4.24,
PostgreSQL 16.2 (pgserver), Dart 3.13.5. Les résultats ci-dessous proviennent
d'exécutions réelles dans cet environnement (aucun test n'est déclaré passant sans exécution).

## 1. Smoke E2E API — `scripts/smoke_e2e.sh` — **34/34 RÉUSSIS**

Exécute le parcours métier complet contre le serveur Laravel réel + PostgreSQL réel.

| # | Scénario (spéc. §10) | Résultat |
|---|---|---|
| 1 | Login : mauvais mot de passe → 401 ; jeton obtenu | ✅ |
| 2 | Route protégée sans jeton → 401 | ✅ |
| 3 | Client créé ; détection de doublon (A1, A3) | ✅ |
| 4 | Tarif actif du catalogue = 1 500 Ar/page (B9) | ✅ |
| 5 | Demande 60 pages : prix indicatif **90 000 Ar** + informations manquantes (B10, A4) | ✅ |
| 6 | Qualification : réponse enregistrée, info déjà fournie non redemandée (A7) | ✅ |
| 7 | prepare-quote → devis ; présentation → `presente` (B11) | ✅ |
| 8 | Acceptation + confirmation → commande créée (C15/C16) | ✅ |
| 9 | Répétition de l'acceptation → **même commande** (idempotence, F37) | ✅ |
| 10 | `livree` directe → 409 LIVRAISON_REQUISE (C19) | ✅ |
| 11 | 2 projets dans une commande (C17) | ✅ |
| 12 | Livraison décrite → commande `livree` | ✅ |
| 13 | Facture total 90 000 ; paiement 30 000 → solde 60 000, `partiellement_payee` (D21) | ✅ |
| 14 | Même clé d'idempotence → paiement idempotent, solde inchangé (D25) | ✅ |
| 15 | Trop-perçu 70 000 → 409 TROP_PERCU (règle V1) | ✅ |
| 16 | Paiement 60 000 → `payee` (D24) | ✅ |
| 17 | Message prérempli avec variables (E28) | ✅ |
| 18 | Copier ≠ envoyé ; confirmation manuelle explicite (E30/E31) | ✅ |
| 19 | Synthèse : recettes = 90 000, facture émise = 90 000 (D27) | ✅ |
| 20 | Push dépense → `synced` ; répétition même clé → pas de doublon (F37) | ✅ |
| 21 | Pull → curseur avancé (F35/F36) | ✅ |
| 22 | Push `base_version` divergente → résultat `conflict`, aucun écrasement (F39) | ✅ |
| 23 | Audit : `creation_depuis_devis` + `livraison` tracées (règle 14) | ✅ |
| 24 | Logout → jeton révoqué → 401 (G48) | ✅ |

(34 vérifications au total incluant les variantes.)

## 2. Tests du cœur Dart — `packages/core` — **36/36 RÉUSSIS**

`cd packages/core && dart test` (exécutable sans Flutter).

| Groupe | Couverture |
|---|---|
| Machines à états (9 tests) | transitions interdites refusées (C18) : `en_preparation→livree`, `accepte→refuse`, `a_qualifier→gagnee`, `emise→brouillon`… |
| Quantités/montants (6 tests) | **60 × 1 500 = 90 000 Ar** (B10), décimal exact `2,5` → 50 000, canonisation, rejets (négatif, 4 décimales, 0), jamais de flottant |
| Statuts financiers (5 tests) | solde 60 000 (D21), en attente non compté (D22), annulé non compté (D23), payée (D24), format français |
| Migrations (4 tests) | 27 tables créées sur base vide (§11.1), FK refusée, CHECK refusé, **C1 : 2 révisions de devis sur une commande** |
| Outbox atomique (4 tests) | écriture + opération dans la même transaction, version +1, **survie fermeture/réouverture** (F33), suppression logique |
| Push (4 tests) | synced après confirmation (F34), coupure réseau → rien perdu (F38), idempotence par clé (F37), échec conservé avec message |
| Pull (3 tests) | application + curseur (F35/F36), tombstone ligne conservée + entité inconnue ignorée (F42), version locale ≥ serveur ignorée |
| Conflits (1 test) | les DEUX versions conservées dans sync_conflicts (F39) |
| État (1 test) | opérations en attente, conflits, curseur lisibles |

## 3. Migrations serveur sur bases vides (§11.1)

- PostgreSQL 16.2 : `php artisan migrate:fresh` → **12/12 DONE** ✓
- SQLite : identique (CHECK gérés par le domaine + schéma Drift local) ✓
- Seed catalogue versionné : 8 services + tarifs + 4 modèles de messages ✓

## 4. Ce qui n'a PAS pu être exécuté ici (blocages réels)

| Élément | Raison | Compensé par |
|---|---|---|
| Compilation APK Android | pas d'Android SDK dans cet environnement (Linux sans toolchain) | `scripts/build_apk.sh` prêt à l'emploi |
| Compilation Windows EXE | pas de toolchain MSVC sur Linux | `scripts/build_windows.ps1` prêt à l'emploi |
| Analyse statique Flutter (`flutter analyze`) | SDK Flutter absent | cœur Dart analysé + testé (36 tests) ; UI écrite selon les APIs stables |
| Test de restauration serveur complet | nécessite un serveur de production | procédure documentée pas à pas (docs/05-securite.md) |
| Synchronisation sur VRAIS appareils Android/Windows | pas d'émulateur dans le sandbox | moteur sync testé de bout en bout avec API factice + API réelle |

Conformément aux règles du projet : **aucun APK, aucun EXE et aucun envoi
Facebook/WhatsApp n'est déclaré produit.**
