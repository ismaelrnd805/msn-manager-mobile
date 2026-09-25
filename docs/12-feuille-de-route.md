# 12 — Feuille de route

La v1 est complète et autonome (offline-first, 14 modules actifs, workflows, documents, sync préparée). Les extensions ci-dessous sont prévues dans l'architecture sans être bloquantes : aucune n'est un prérequis du cœur métier.

## 1. Modules futurs déjà prévus

Le registre `core/modules/module_registry.dart` réserve trois entrées (seedées désactivées dans `DemoData`, `core: false`) :

| Code | Intitulé | Contenu prévu |
|---|---|---|
| `crm_avance` | CRM avancé | Segmentation clients, campagnes, statistiques clients. |
| `comptabilite_avance` | Comptabilité avancée | Grand livre, TVA, exports comptables. |
| `module_avance` | Module avancé | Fonctionnalités métier étendues futures. |

Branchement : suivre 06-ajouter-module.md (descripteur déjà présent, il reste l'écran, la route, l'entrée MoreScreen). Le flag passe à `true` dans `/settings/modules` le jour de la mise en service.

## 2. Intégrations envisagées

| Intégration | Ce qui existe déjà | Ce qu'il faut ajouter |
|---|---|---|
| Messenger / WhatsApp Business | `ShareService.shareText/shareFile` : bascule native vers l'application choisie ; canal d'origine connu (`Canal.messenger`, `Canal.whatsapp`) | API Cloud WhatsApp Business / Messenger Send : service d'envoi optionnel appelé depuis le compositeur, journalisé comme les messages manuels. |
| Email | Modèles de messages réutilisables | Envoi SMTP côté serveur NestJS (jamais depuis le mobile : offline-first) ou intention `mailto:`. |
| Paiements en ligne | Paiements manuels toutes méthodes locales (`PaymentMethode`) : MVola, Orange Money, Airtel Money, virement | Lien de paiement dans `{{LIEN}}`, webhook serveur -> `sync/batch` vers le mobile (nouveau `RemoteChange` `payments`). |
| IA | Qualification structurée (JSON) | Aide à la rédaction de messages et au résumé de brief ; appel serveur, résultats stockés comme données métier classiques. |
| Statistiques | DAOs et Streams réactifs | Module `statistiques` (voir 06) ; agrégations SQL locales, aucune dépendance réseau. |
| MSN Manager Desktop | Contrats `/api/v1` stables ; `sync_log` serveur versionné | Client desktop consommant les mêmes endpoints ; le mobile pull les changements créés par le PC (appliers par entité, voir 04). |

## 3. Pourquoi rien de tout cela ne bloque la v1

1. **L'application est déjà complète sans serveur** : demandes -> devis -> commandes -> factures -> paiements -> workflows -> archivage fonctionnent 100% hors ligne.
2. **La synchronisation est optionnelle et contractée** : `ApiClient` + `SyncPayload`/`RemoteChange` sont figés ; le serveur se développe sans retoucher au mobile (tant que `/api/v1` respecte les contrats de 05-backend-nestjs.md).
3. **Le système de modules isole les ajouts** : activer `crm_avance` ne modifie aucun flux existant (garde `moduleRegistryProvider`, UI conditionnelle).
4. **Les notifications sont déjà découplées** : `NotificationService` centralise l'affichage (canaux « Rappels MSN », « Alertes MSN ») ; « Si l'initialisation échoue … les rappels restent visibles dans l'application — aucune perte de fonctionnalité métier ».

## 4. Comment chaque extension se branche

**Nouveau module** (statistiques, CRM avancé…) :
1. descripteur `ModuleCatalog` (déjà fait pour les trois futurs),
2. dossier `lib/features/<module>/`,
3. route go_router,
4. garde `registry.isActive(code)`,
5. entrée `MoreScreen`,
6. activation dans `module_flags`.

**Nouvelle entité synchronisée** (ex. campagnes CRM) :
1. table locale + migration (02),
2. écritures métier avec `syncEngineProvider.enqueue(entite: 'campagnes', …)`,
3. applier `remoteAppliers['campagnes']` pour le pull (04),
4. table `sync_log` côté serveur ; aucun changement de contrat si `entite` est simplement une nouvelle valeur.

**Notifications push (FCM)** :
1. ajouter `firebase_messaging` et l'initialisation dans `NotificationService.init` (le service est explicitement conçu pour « recevoir des notifications push sans modifier ce service ») ;
2. le serveur publie un message de data (ex. « des changements sont disponibles ») -> le mobile déclenche `syncControllerProvider.runNow()` ;
3. les notifications locales (rappels) gardent leur canal dédié : aucune collision d'identifiants.

**MSN Manager Desktop** :
1. le PC devient producteur et consommateur de changements (`POST /sync/batch`, `GET /sync/changes`) ;
2. le mobile pull : le workflow LOGO peut être lancé depuis le PC (étape Production), la progression revient au mobile par pull ;
3. mêmes règles de conflit des deux côtés (jamais d'écrasement silencieux, `sync_conflicts`).

**Paiements en ligne** :
1. webhook opérateur télécom -> serveur NestJS,
2. le serveur écrit dans `sync_log` (`entite: 'payments'`),
3. le mobile pull -> applier `payments` -> facture mise à jour, statut recalculé par `QuoteCalculator.facture`, notification locale au bureau.

Priorité conseillée après mise en production de la v1 : (1) serveur LAN + sync clients/requests/orders, (2) module Statistiques, (3) WhatsApp Business API, (4) CRM avancé, (5) comptabilité avancée.

## 5. Phases

| Phase | Contenu | Prérequis |
|---|---|---|
| v1 (livrée) | App offline-first complète, 14 modules actifs, workflows LOGO/MÉMOIRE/générique, documents, sauvegarde JSON, tests métier. | Aucun serveur. |
| v1.1 | Serveur NestJS LAN (`/api/v1`), sync clients + requests + orders, auth JWT. | Poste local + PostgreSQL. |
| v1.2 | Module Statistiques ; appliers restants (quotes, invoices, payments) ; conflits via `/sync`. | v1.1. |
| v1.3 | WhatsApp Business API (envoi), notifications FCM « changements disponibles ». | Compte Meta Business, Firebase. |
| v2 | CRM avancé, MSN Manager Desktop sur les mêmes contrats, paiements en ligne (webhook -> sync). | v1.2 + HTTPS. |
| v2+ | Comptabilité avancée (grand livre, TVA), IA d'aide à la rédaction, module_avance. | Selon besoin métier. |

Chaque phase reste réversible et indépendante : désactiver un module, vider `server_url` ou ignorer FCM ramène l'application dans son mode purement local, sans perte de fonctionnalité métier.
