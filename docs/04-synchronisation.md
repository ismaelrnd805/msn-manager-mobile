# Synchronisation hors ligne (Android ↔ Windows via le serveur)

## Principe

Deux bases SQLite ne se synchronisent **jamais** entre elles. Le serveur central
PostgreSQL est l'arbitre : chaque appareil pousse ses opérations locales et tire
les changements des autres. L'application reste **entièrement utilisable hors ligne**.

## Cycle

1. **Écriture locale** : toute modification métier (client, demande, devis,
   paiement…) est écrite avec une opération d'outbox **dans la même transaction
   Drift** — une fermeture forcée ne perd rien.
2. **Push** (lot ≤ 100, spec §8.6) :
   - opérations passées en `in_flight` ;
   - le serveur vérifie jeton + appareil, rejoue les clés d'idempotence
     (`sync_push_log`), compare `base_version`, applique les règles métier,
     répond opération par opération (`synced` / `conflict` / `failed`) ;
   - `synced` uniquement après confirmation serveur ; `conflict` → conservé dans
     `sync_conflicts` (les DEUX versions) ; `failed` → retenté avec message.
3. **Pull** (curseur monotone) :
   - `GET /sync/pull?cursor=N` sert le journal global `sync_journal` ;
   - le lot est appliqué **dans une seule transaction locale** ;
   - le curseur n'avance qu'après application complète réussie ;
   - les suppressions sont des tombstones (`deleted_at`), jamais physiques.

## Déclencheurs (spec §8.6)

lancement de l'app · retour au premier plan · après chaque modification (si
réseau disponible) · action manuelle (bouton sync).

## Défaillances réseau

- API injoignable → `ApiInatteignable` → opérations `in_flight` repassées en
  `pending` (rien n'est perdu) ;
- temporisation progressive du planificateur : délai = min(2^tentatives, 300 s) ;
- reprise sans doublon grâce à la clé d'idempotence (test F37).

## Conflits (spec §8.5)

| Donnée | Politique |
|---|---|
| Champs indépendants non sensibles | fusion possible (règle documentée par champ) |
| Client/contact : mêmes champs modifiés | les deux versions sont présentées à l'utilisateur |
| Devis accepté, facture émise, paiement confirmé, commande livrée | **jamais** « dernier arrivé gagne » — rectification auditable |

Le serveur protège les champs sensibles (`statut`, `numero`, `total`…) contre
l'écrasement par sync générique : `CHAMP_PROTEGE` — les transitions passent par
des actions métier explicites (`/transition`, `/delivery`, `/payments`).

## Fichiers (pièces jointes)

- métadonnées en base (`pieces_jointes`), transfert **séparé** du push/pull ;
- `POST /attachments` (déclare taille + SHA-256) → `PUT /attachments/{id}/content`
  → `POST /attachments/{id}/complete` (vérifie taille + empreinte) ;
- états locaux : `local` / `a_transferer` / `transfert_en_cours` / `synchronise` / `echec` ;
- limite 25 Mo par fichier (V1) ;
- `GET /attachments/{id}/download` pour l'autre appareil.

## État visible dans l'interface

Le rail de navigation affiche : nombre d'opérations en attente, conflits non
résolus, curseur, dernière synchronisation réussie. Aucune action ne laisse
l'utilisateur croire à une synchronisation qui n'a pas eu lieu.
