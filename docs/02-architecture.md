# Architecture

## Vue d'ensemble

```
┌──────────────────────┐        HTTPS/JSON         ┌──────────────────────┐
│  Flutter Android     │ ◄───────────────────────► │  API Laravel /api/v1 │
│  Flutter Windows     │   jetons Sanctum court    │  règles métier       │
│  ┌────────────────┐  │   + refresh 30 jours      │  autoritaires        │
│  │ UI (français)  │  │                           └──────────┬───────────┘
│  ├────────────────┤  │                                      │
│  │ packages/core  │  │            ┌──────────────┐          │
│  │ (Dart pur)     │  │            │ PostgreSQL   │◄─────────┘
│  │ · domaine      │  │            │ central      │
│  │ · Drift/SQLite │  │            └──────────────┘
│  │ · outbox       │  │
│  │ · moteur sync  │  │
│  └────────────────┘  │
└──────────────────────┘
```

## Séparation stricte (exigence §3 de la spécification)

| Couche | Emplacement | Contenu |
|---|---|---|
| Interface | `packages/msn_ui/lib/ui/` | écrans partagés, navigation adaptative — aucune règle métier |
| État | `packages/msn_ui/lib/state/` | providers Riverpod, réglages |
| Apps | `apps/mobile` (Android) · `apps/desktop` (Windows) | points d'entrée minces, une plateforme chacune |
| Domaine | `packages/core/lib/domain/` | machines à états, quantités, argent, libellés |
| Stockage | `packages/core/lib/data/` | tables Drift, migrations v1, outbox atomique |
| Synchronisation | `packages/core/lib/sync/` | push/pull, conflits, curseur |
| Serveur | `server/api/app/Domain/` | règles AUTORITAIRES (le client ne fait pas autorité) |

**Règle d'or** : le serveur revalide tout (transitions, montants, idempotence).
Le client peut être hors ligne, en retard ou compromis — l'intégrité reste garantie.

## Parcours commercial (spéc. §6)

```
Client (Messenger/WhatsApp/téléphone/présentiel)
  → client recherché ou créé (doublons signalés)
  → DEMANDE (message initial conservé tel quel)   [peut rester sans commande]
  → qualification (questions par service, réponses conservées avec trace)
  → DEVIS (brouillon → présenté ; révisions historisées ; prix = instantanés)
  → acceptation + confirmation → COMMANDE (atomique, idempotente)
      → projets multiples, tâches, échéances
      → livraison enregistrée → « livrée »
      → FACTURE (≤ 1 par commande, lignes = instantanés)
      → PAIEMENTS (confirmés seulement → solde) → statuts financiers calculés
```

## Décisions d'implémentation documentées

| # | Décision | Source |
|---|---|---|
| C1 | `devis.commande_id` SANS UNIQUE — « une seule version courante » = règle métier | docs/01-jalon0-inspection.md |
| C2 | `UNIQUE(demande_id, service_id)` conservée ; lots multiples via details_json | spec §5.1 |
| C3 | Quantités = TEXT décimal exact en SQLite, NUMERIC(12,3) en PG | spec §3 |
| C4 | `POST /devis/{id}/accept` = voie canonique de création de commande | spec §6.F |
| C7 | Table `publications_facebook` ajoutée (module 13) | spécification produit |
| C8 | Table `sync_journal` (séquence monotone) pour le pull | spec §8.4 |

Voir `docs/01-jalon0-inspection.md` pour la liste complète et les justifications.

## Idempotence et versions

- chaque opération locale porte `idempotency_key` (UUID) et `base_version` ;
- le serveur mémorise les clés traitées (`sync_push_log`) et rejoue le résultat ;
- divergence de version → réponses `conflict` avec l'état serveur, aucun écrasement ;
- le client stocke les conflits dans `sync_conflicts` pour résolution auditable.
