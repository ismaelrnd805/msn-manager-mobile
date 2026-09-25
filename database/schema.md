# Schéma de la base — référence des 28 tables

Source de vérité : `lib/core/database/tables.dart` (Drift), version de schéma 3 (`app_database.dart`). Types Drift : `TEXT`, `INTEGER`, `REAL`, `BOOLEAN`, `DATETIME` (stockés en SQLite : texte, entier, réel, 0/1, entier horodaté). Conventions : `dateTime().withDefault(currentDateAndTime)` est noté `défaut = maintenant`.

## Colonnes transverses (tables métier synchronisées)

Les tables **clients, services, requests, quotes, invoices, orders** portent toutes :

| Colonne | Type | Contraintes | Rôle |
|---|---|---|---|
| createdAt | DATETIME | défaut = maintenant | Création locale. |
| updatedAt | DATETIME | défaut = maintenant | Dernière modification locale (comparaison de sync). |
| lastSyncedAt | DATETIME | nullable | Dernière application d'un changement distant. |
| deletedAt | DATETIME | nullable | Suppression douce (corbeille) — NULL = vivant. |

Notation ci-dessous : « + transverses » = ces quatre colonnes s'ajoutent aux colonnes listées.

## 1. Utilisateurs & sécurité

### `users` — comptes locaux (PIN, rôle)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| nom | TEXT | NOT NULL |
| pinHash | TEXT | NOT NULL (SHA-256 salé `msn-<pin>`) |
| role | TEXT | défaut `operateur` (enum UserRole) |
| actif | BOOLEAN | défaut true |
| createdAt | DATETIME | défaut = maintenant |
| lastSyncedAt | DATETIME | nullable |

## 2. CRM

### `clients` — fiches clients
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| nom | TEXT | NOT NULL |
| telephone | TEXT | nullable |
| email | TEXT | nullable |
| canalPrefere | TEXT | nullable (enum Canal) |
| adresse | TEXT | nullable |
| notes | TEXT | nullable |
| + transverses | | |

## 3. Catalogue

### `categories` — catégories de services
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| nom | TEXT | NOT NULL |
| ordre | INTEGER | défaut 0 |
| actif | BOOLEAN | défaut true |
| createdAt | DATETIME | défaut = maintenant |

### `services` — services et tarifs
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| nom | TEXT | NOT NULL |
| description | TEXT | nullable |
| categoryId | TEXT | nullable, FK -> categories.id |
| prixBase | INTEGER | défaut 0 (Ariary) |
| unite | TEXT | défaut `forfait` |
| delaiJours | INTEGER | nullable |
| inclus | TEXT | nullable |
| exclusions | TEXT | nullable |
| conditions | TEXT | nullable |
| actif | BOOLEAN | défaut true |
| + transverses | | |

## 4. Demandes

### `requests` — demandes clients (index `idx_requests_statut` sur statut)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| reference | TEXT | NOT NULL, UNIQUE (REQ-AAAA-NNNN) |
| clientId | TEXT | NOT NULL, FK -> clients.id |
| canal | TEXT | NOT NULL (enum Canal) |
| serviceId | TEXT | nullable, FK -> services.id |
| description | TEXT | nullable |
| deadlineSouhaitee | DATETIME | nullable |
| budget | INTEGER | nullable |
| priorite | TEXT | défaut `normale` (enum Priorite) |
| statut | TEXT | défaut `nouvelle` (enum RequestStatut) |
| notes | TEXT | nullable |
| qualificationJson | TEXT | nullable (réponses du formulaire) |
| + transverses | | |

## 5. Qualification dynamique

### `qualification_forms` — formulaires par service
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| serviceId | TEXT | nullable, FK -> services.id |
| nom | TEXT | NOT NULL |
| actif | BOOLEAN | défaut true |
| createdAt | DATETIME | défaut = maintenant |

### `qualification_questions` — questions d'un formulaire
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| formId | TEXT | NOT NULL, FK -> qualification_forms.id |
| ordre | INTEGER | défaut 0 |
| label | TEXT | NOT NULL |
| type | TEXT | défaut `texte` (enum QuestionType) |
| optionsJson | TEXT | nullable (choix pour type `liste`) |
| obligatoire | BOOLEAN | défaut false |

## 6. Workflows

### `workflow_templates` — modèles de workflow (par service ou génériques)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| serviceId | TEXT | nullable, FK -> services.id |
| nom | TEXT | NOT NULL |
| description | TEXT | nullable |
| actif | BOOLEAN | défaut true |
| createdAt | DATETIME | défaut = maintenant |

### `workflow_steps` — étapes ordonnées d'un modèle
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| workflowId | TEXT | NOT NULL, FK -> workflow_templates.id |
| ordre | INTEGER | NOT NULL |
| nom | TEXT | NOT NULL |
| actionsJson | TEXT | défaut `[]` (codes d'actions prêtes) |

### `workflow_instances` — exécution d'un workflow pour une commande
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| orderId | TEXT | NOT NULL, FK -> orders.id |
| workflowId | TEXT | NOT NULL, FK -> workflow_templates.id |
| statut | TEXT | défaut `actif` |
| currentStepIndex | INTEGER | défaut 0 |
| startedAt | DATETIME | défaut = maintenant |
| completedAt | DATETIME | nullable |

### `workflow_step_states` — état de chaque étape instanciée
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| instanceId | TEXT | NOT NULL, FK -> workflow_instances.id |
| stepId | TEXT | NOT NULL, FK -> workflow_steps.id |
| ordre | INTEGER | NOT NULL |
| nom | TEXT | NOT NULL |
| actionsJson | TEXT | défaut `[]` |
| statut | TEXT | défaut `en_attente` (en_attente/terminee/bloquee) |
| completedAt | DATETIME | nullable |
| note | TEXT | nullable |

## 7. Règles métier & exceptions

### `business_rules` — règles par service (clé/valeur)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| serviceId | TEXT | nullable, FK -> services.id |
| cle | TEXT | NOT NULL (ex. `acompte_obligatoire`) |
| valeur | TEXT | NOT NULL |
| description | TEXT | nullable |
| UNIQUE | | (serviceId, cle) |

### `rule_exceptions` — exceptions autorisées (raison + utilisateur + date)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| orderId | TEXT | nullable, FK -> orders.id |
| ruleKey | TEXT | NOT NULL |
| raison | TEXT | NOT NULL |
| userName | TEXT | NOT NULL |
| createdAt | DATETIME | défaut = maintenant |

## 8. Devis

### `quotes` — devis (référence DEV-AAAA-NNNN)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| reference | TEXT | NOT NULL, UNIQUE |
| clientId | TEXT | NOT NULL, FK -> clients.id |
| requestId | TEXT | nullable, FK -> requests.id |
| statut | TEXT | défaut `brouillon` (enum QuoteStatut) |
| reduction | INTEGER | défaut 0 |
| acompte | INTEGER | défaut 0 |
| delaiJours | INTEGER | nullable |
| conditions | TEXT | nullable |
| validiteJours | INTEGER | défaut 15 |
| montantTotal | INTEGER | défaut 0 |
| dateEmission | DATETIME | défaut = maintenant |
| + transverses | | |

### `quote_items` — lignes de devis
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| quoteId | TEXT | NOT NULL, FK -> quotes.id |
| serviceId | TEXT | nullable, FK -> services.id |
| designation | TEXT | NOT NULL |
| quantite | REAL | défaut 1.0 |
| prixUnitaire | INTEGER | défaut 0 |
| ordre | INTEGER | défaut 0 |

## 9. Factures

### `invoices` — factures (référence FAC-AAAA-NNNN)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| reference | TEXT | NOT NULL, UNIQUE |
| clientId | TEXT | NOT NULL, FK -> clients.id |
| orderId | TEXT | nullable, FK -> orders.id |
| quoteId | TEXT | nullable, FK -> quotes.id |
| statut | TEXT | défaut `brouillon` (enum InvoiceStatut) |
| reduction | INTEGER | défaut 0 |
| montantTotal | INTEGER | défaut 0 |
| conditions | TEXT | nullable |
| dateEmission | DATETIME | défaut = maintenant |
| dateEcheance | DATETIME | nullable |
| + transverses | | |

### `invoice_items` — lignes de facture
Mêmes colonnes que `quote_items`, avec `invoiceId` NOT NULL, FK -> invoices.id (au lieu de `quoteId`).

## 10. Paiements

### `payments` — paiements (référence PMT-AAAA-NNNN ; index `idx_payments_invoice` sur invoice_id)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| reference | TEXT | NOT NULL, UNIQUE |
| clientId | TEXT | nullable, FK -> clients.id |
| invoiceId | TEXT | nullable, FK -> invoices.id |
| orderId | TEXT | nullable, FK -> orders.id |
| montant | INTEGER | NOT NULL (Ariary) |
| methode | TEXT | NOT NULL (enum PaymentMethode : especes, mvola, orangeMoney, airtelMoney, virement, autre) |
| referenceExterne | TEXT | nullable (ex. réf. MVola) |
| note | TEXT | nullable |
| datePaiement | DATETIME | défaut = maintenant |
| createdAt | DATETIME | défaut = maintenant |
| lastSyncedAt | DATETIME | nullable |

## 11. Commandes

### `orders` — commandes (référence CMD-AAAA-NNNN ; index `idx_orders_statut` sur statut)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| reference | TEXT | NOT NULL, UNIQUE |
| clientId | TEXT | NOT NULL, FK -> clients.id |
| serviceId | TEXT | nullable, FK -> services.id |
| requestId | TEXT | nullable, FK -> requests.id |
| quoteId | TEXT | nullable, FK -> quotes.id |
| titre | TEXT | NOT NULL |
| statut | TEXT | défaut `enCours` (enum OrderStatut) |
| deadline | DATETIME | nullable |
| montantTotal | INTEGER | défaut 0 |
| acompteRequis | INTEGER | défaut 0 |
| briefComplet | BOOLEAN | défaut false |
| conditionsAcceptees | BOOLEAN | défaut false |
| pretPourProduction | BOOLEAN | défaut false |
| transferePc | BOOLEAN | défaut false |
| transfereLe | DATETIME | nullable |
| notes | TEXT | nullable |
| + transverses | | |

### `order_files` — fichiers rattachés (miroir des dossiers PC)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| orderId | TEXT | nullable, FK -> orders.id |
| requestId | TEXT | nullable, FK -> requests.id |
| dossier | TEXT | défaut `documents` (enum DossierFichier : source, travail, corrections, final_, documents) |
| nom | TEXT | NOT NULL |
| cheminLocal | TEXT | nullable |
| taille | INTEGER | nullable |
| mime | TEXT | nullable |
| origine | TEXT | défaut `mobile` |
| note | TEXT | nullable |
| createdAt | DATETIME | défaut = maintenant |

## 12. Communication

### `message_templates` — modèles de messages (14 de démo)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| code | TEXT | NOT NULL, UNIQUE (ex. DEMANDE_ACOMPTE) |
| titre | TEXT | NOT NULL |
| categorie | TEXT | NOT NULL (enum TemplateCategorie, 14 catégories) |
| corps | TEXT | NOT NULL (variables `{{VAR}}`) |
| actif | BOOLEAN | défaut true |
| ordre | INTEGER | défaut 0 |
| updatedAt | DATETIME | défaut = maintenant |

## 13. Rappels & tâches

### `reminders` — rappels planifiés (notifications locales)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| titre | TEXT | NOT NULL |
| description | TEXT | nullable |
| type | TEXT | NOT NULL (enum ReminderType) |
| cibleType | TEXT | nullable (ex. `order`) |
| cibleId | TEXT | nullable |
| dateRappel | DATETIME | NOT NULL |
| termine | BOOLEAN | défaut false |
| notifie | BOOLEAN | défaut false |
| createdAt | DATETIME | défaut = maintenant |

### `tasks` — tâches (ajoutée en migration v2)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| titre | TEXT | NOT NULL |
| description | TEXT | nullable |
| priorite | TEXT | défaut `normale` (enum Priorite) |
| echeance | DATETIME | nullable |
| statut | TEXT | défaut `aFaire` (enum TaskStatut) |
| cibleType | TEXT | nullable |
| cibleId | TEXT | nullable |
| createdAt | DATETIME | défaut = maintenant |

## 14. Journal & paramètres

### `activity_log` — journal d'activité
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK |
| timestamp | DATETIME | défaut = maintenant |
| userName | TEXT | NOT NULL |
| action | TEXT | NOT NULL (enum ActivityAction) |
| entite | TEXT | NOT NULL |
| entityId | TEXT | nullable |
| details | TEXT | NOT NULL |

### `settings` — paramètres clé/valeur (compteurs REQ/DEV/CMD/FAC/PMT, server_url, last_sync_at…)
| Colonne | Type | Contraintes |
|---|---|---|
| cle | TEXT | PK |
| valeur | TEXT | NOT NULL |

### `module_flags` — état d'activation des modules
| Colonne | Type | Contraintes |
|---|---|---|
| code | TEXT | PK (ex. `clients`, `crm_avance`) |
| actif | BOOLEAN | défaut true |
| ordre | INTEGER | défaut 0 |

## 15. Synchronisation

### `sync_queue` — file d'attente push (index `idx_sync_queue_statut` sur statut)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK (`sq_<horodatage>_<hash>`) |
| entite | TEXT | NOT NULL (nom de table serveur) |
| entityId | TEXT | NOT NULL |
| operation | TEXT | NOT NULL (enum SyncOperation : create, update, delete) |
| payload | TEXT | NOT NULL (JSON) |
| statut | TEXT | défaut `enAttente` (enum SyncQueueStatut : enAttente, enCours, synchronise, erreur, conflit) |
| tentatives | INTEGER | défaut 0 |
| derniereErreur | TEXT | nullable |
| createdAt | DATETIME | défaut = maintenant |
| updatedAt | DATETIME | défaut = maintenant |

### `sync_conflicts` — conflits de synchronisation (décision humaine)
| Colonne | Type | Contraintes |
|---|---|---|
| id | TEXT | PK (`cf_<horodatage>`) |
| entite | TEXT | NOT NULL |
| entityId | TEXT | NOT NULL |
| localPayload | TEXT | NOT NULL (JSON) |
| remotePayload | TEXT | NOT NULL (JSON) |
| statut | TEXT | défaut `ouvert` (`ouvert` / résolution) |
| detecteLe | DATETIME | défaut = maintenant |
| resoluLe | DATETIME | nullable |

## Clés de compteurs (`settings`)

`NumberingService` / `AppDatabase.nextSequence` utilisent les clés `counter_{PREFIX}_{annee}` (REQ, DEV, CMD, FAC, PMT), remises à zéro chaque année ; `IdGenerator.formatReference` produit `REQ-2026-0001`.
