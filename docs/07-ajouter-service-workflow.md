# 07 — Ajouter un service, un formulaire, un workflow et ses règles

Quatre tutoriels complémentaires : le catalogue est éditable **dans l'app sans code** (a, b, d), les workflows se créent par code ou par édition admin/SQL (c), et les codes d'actions sont fixes (e).

## (a) Ajouter un service + tarif au catalogue (via l'app)

Écran **Plus > Catalogue & tarifs** (`/catalog`, module `catalog`), bouton d'ajout -> `ServiceEditScreen` (route `/catalog/new`, édition sur `/catalog/:id/edit`). Champs enregistrés dans la table `services` :

| Champ | Colonne | Exemple |
|---|---|---|
| Nom | `nom` | « Carte de visite » |
| Catégorie | `categoryId` -> `categories` | Design |
| Prix de base | `prixBase` (entier, Ariary) | 25000 |
| Unité | `unite` | `forfait`, `pièce`, `page` |
| Délai (jours) | `delaiJours` | 2 |
| Description | `description` | texte client |
| Inclus / Exclusions / Conditions | `inclus`, `exclusions`, `conditions` | texte libre |

Le tarif est immédiatement utilisé par la fiche PDF, le catalogue PDF et les devis (ligne pré-remplie à `prixBase`). Un changement de tarif est journalisé (`ActivityAction.changementTarif`). Modification réservée à l'admin (`AppPermissions.canManageCatalog`).

## (b) Créer le formulaire de qualification (via l'app, sans code)

Écran **Administration > Qualification** (`/settings/qualification`, `AdminQualificationScreen`, admin uniquement). On crée un `qualification_forms` rattaché à un service, puis des `qualification_questions` :

- libellé (`label`), ordre (`ordre`) ;
- type : `texte` (court), `multiligne`, `nombre`, `date`, `liste` (options en `optionsJson`) ;
- obligatoire (`obligatoire`).

Lors de la qualification d'une demande (`/requests/:id/qualify`), les réponses sont stockées en JSON dans `requests.qualificationJson`. C'est ce JSON qui alimente le badge « Brief complet » de la commande et la vérification `brief_complet` du moteur de règles. Les formulaires de démo (`form_logo`, `form_memoire`, `form_affiche`) servent de modèle.

## (c) Créer un workflow (par code ou SQL)

Un workflow = `workflow_templates` (nom + service optionnel) + `workflow_steps` (étapes ordonnées). Chaque étape porte `actionsJson` : la liste des **codes d'actions prêtes** (voir (e)).

**Par code** — modèle `createWorkflow` de `core/database/seed/demo_data.dart` :

```dart
Future<void> createWorkflow(String id, String nom, String? serviceId,
    List<String> steps) async {
  await db.into(db.workflowTemplates).insert(
        WorkflowTemplatesCompanion.insert(id: id, nom: nom, serviceId: Value(serviceId)),
      );
  var i = 0;
  for (final step in steps) {
    await db.into(db.workflowSteps).insert(WorkflowStepsCompanion.insert(
          id: '${id}_s$i', workflowId: id, ordre: i, nom: step,
          actionsJson: Value(jsonEncode(_actionsFor(step))),
        ));
    i++;
  }
}

await createWorkflow('wf_cartes', 'Workflow Cartes de visite', 'svc_cartes', [
  'Réception', 'Qualification', 'Devis', 'Validation', 'Acompte',
  'Production', 'Livraison', 'Paiement final', 'Archivage',
]);
```

Les workflows de démo existants : `wf_logo` (13 étapes : Réception -> Qualification -> Devis -> Validation -> Acompte -> Brief complet -> Production -> Proposition V1 -> Correction -> Validation finale -> Livraison -> Paiement final -> Archivage), `wf_memoire` (13 étapes), `wf_generic` (9 étapes, sans service).

**Par SQL / édition admin** (sans réinstaller) :

```sql
INSERT INTO workflow_templates (id, nom, service_id, actif, created_at)
VALUES ('wf_cartes', 'Workflow Cartes de visite', 'svc_cartes', 1, datetime('now'));
INSERT INTO workflow_steps (id, workflow_id, ordre, nom, actions_json)
VALUES ('wf_cartes_s0', 'wf_cartes', 0, 'Réception', '["MESSAGE_ACCUEIL"]');
-- … étapes suivantes …
```

À la création de la commande, `bootstrapWorkflowForOrder` (`core/workflow_bootstrap.dart`) choisit le workflow du service (`templateForService`), sinon le générique, et instancie les étapes dans `workflow_instances` / `workflow_step_states`.

## (d) Définir les règles métier du service

Règles stockées dans `business_rules` (clé/valeur texte par service, table unique `(serviceId, cle)`). Clés de `RuleKeys` (`core/constants/app_constants.dart`) :

| Clé | Type | Effet (moteur `BusinessRuleEngine`) |
|---|---|---|
| `acompte_obligatoire` | bool | Bloque les étapes Acompte/Production si `totalPaye <= 0`. |
| `propositions_incluses` | int | Nombre de propositions prévues (Logo : 2). |
| `corrections_incluses` | int | Nombre de corrections prévues (Logo : 2). |
| `paiement_final_avant_livraison` | bool | Bloque la Livraison si `totalPaye < totalCommande`. |
| `validation_finale_obligatoire` | bool | Bloque la Livraison sans validation client. |

Insertion type (celle du service Logo) :

```dart
const logoRules = {
  RuleKeys.acompteObligatoire: 'true',
  RuleKeys.propositionsIncluses: '2',
  RuleKeys.correctionsIncluses: '2',
  RuleKeys.paiementFinalAvantLivraison: 'true',
  RuleKeys.validationFinaleObligatoire: 'true',
};
```

Une violation affiche le message du moteur ; l'opérateur peut la contourner par une **EXCEPTION AUTORISÉE** (raison + utilisateur + date, table `rule_exceptions`, `ActivityAction.exceptionRegles`), réservée à l'admin (`AppPermissions.canOverrideRules`). L'appariement des règles se fait sur des mots-clés du nom d'étape (`acompte`, `production`/`brief`, `livr`) : renommer légèrement une étape ne casse pas le moteur.

## (e) Codes d'actions disponibles (`ActionCatalog`)

`core/domain/workflow_engine.dart`. `ActionCatalog.typeOf(code)` choisit le comportement de l'UI :

| Code | Libellé affiché | Type |
|---|---|---|
| `MESSAGE_ACCUEIL` | Message d'accueil | message |
| `MESSAGE_TARIF` | Présenter le tarif | message |
| `MESSAGE_DEVIS` | Envoyer le devis | message |
| `DEMANDER_ACOMPTE` | Demander l'acompte | messagePaiement |
| `ENREGISTRER_ACOMPTE` | Enregistrer l'acompte | paiement |
| `DEMANDER_FICHIERS` | Demander les fichiers | fichiers |
| `RECEVOIR_FICHIERS` | Réceptionner les fichiers | fichiers |
| `PRODUIRE` | Production (PC) | production |
| `PROPOSER_LIVRAISON` | Proposer la livraison | tache |
| `DEMANDER_VALIDATION` | Demander la validation | validation |
| `VALIDER` | Valider (client) | validation |
| `APPLIQUER_CORRECTIONS` | Appliquer les corrections | tache |
| `LIVRER` | Livrer | tache |
| `DEMANDER_SOLDE` | Demander le solde | messagePaiement |
| `ENREGISTRER_PAIEMENT` | Enregistrer le paiement final | paiement |
| `ARCHIVER` | Archiver | tache |
| `TRANSFERE_PC` | Transférer au PC | production |
| `CONTROLE` | Contrôle qualité | validation |
| `ANALYSE` | Analyse de la demande | tache |

Types : `message` ouvre le compositeur pré-rempli, `paiement` ouvre le formulaire de paiement, `fichiers` la réception de fichiers, `production` le transfert PC, `validation` la demande/confirmation de validation, `tache` une action générique cochable.
