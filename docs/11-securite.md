# 11 — Sécurité

Sécurité pensée pour un téléphone métier mono-poste (ou petit équipe) : authentification locale par PIN, session mémoire, permissions par rôle, journalisation intégrale des opérations sensibles.

## 1. Authentification PIN

- Le PIN n'est **jamais** stocké en clair : hachage SHA-256 salé dans `DemoData.hashPin` :

```dart
static String hashPin(String pin) =>
    sha256.convert(utf8.encode('msn-$pin')).toString();
```

- Stockage : colonne `users.pinHash` (les comptes démo `Admin`/1234 et `Faniry`/1111 sont seedés une seule fois).
- Vérification : `SessionNotifier.login` (`core/auth/session.dart`) cherche l'utilisateur par nom (`SystemDao.userByName`), refuse les comptes inactifs, compare les hachés, puis journalise la connexion et retient `last_user` dans `settings`.

```dart
if (user == null || !user.actif) {
  throw const AppException('Utilisateur inconnu ou désactivé.');
}
if (user.pinHash != DemoData.hashPin(pin)) {
  throw const AppException('PIN incorrect.');
}
state = Session(userName: user.nom, role: user.role);
```

## 2. Session en mémoire

- `sessionProvider` (`NotifierProvider<SessionNotifier, Session?>`) démarre à `null` et vit uniquement en mémoire : **au redémarrage de l'application, la session est perdue** et une nouvelle connexion est exigée (expiration garantie, aucune session persistée à contourner).
- Le routeur s'abonne à la session (`_SessionListenable` + `refreshListenable`) : sans session, toute route redirige vers `/login` ; avec session, `/login` redirige vers `/dashboard`.
- `changePin` impose 4 chiffres minimum et exige le rôle admin (`PermissionException` sinon).

## 3. Rôles et permissions

Deux rôles (`UserRole`) : `admin` (Administrateur), `operateur` (Opérateur). Actions **admin-only**, centralisées dans `AppPermissions` :

| Méthode | Action protégée |
|---|---|
| `canManageCatalog` | Création/édition de services et tarifs. |
| `canManageModules` | Activation/désactivation des modules (`/settings/modules`). |
| `canManageUsers` | Gestion des utilisateurs, changement de PIN. |
| `canEditTemplates` | Édition des modèles de messages (`/settings/templates`). |
| `canResolveConflicts` | Résolution des conflits de synchronisation. |
| `canPurgeTrash` | Purge définitive de la corbeille (le `DELETE` physique). |
| `canImportBackup` | Restauration d'une sauvegarde JSON (purge + réinjection). |
| `canOverrideRules` | Exceptions autorisées aux règles métier (`rule_exceptions`). |

Verrouillage complémentaire côté navigation : le `redirect` de `appRouterProvider` renvoie vers `/more` tout non-admin tentant d'accéder aux sous-routes `/settings/*` (modules, modèles, qualification, utilisateurs, journal, corbeille). Les tentatives franchies par code lèvent `PermissionException` (« Action réservée : … Connectez-vous avec un compte administrateur. »).

## 4. Validation des entrées

- Formulaires Flutter avec `GlobalKey<FormState>` et `validate()` avant toute écriture (ex. `_save()` de `client_edit_screen.dart`).
- Utilitaires partagés : `core/utils/validators.dart` (champs obligatoires, numéros de téléphone, montants entiers positifs).
- Montants toujours entiers (`int`, Ariary) : pas d'injection de décimaux inattendus dans les totaux.
- Comptes désactivables (`users.actif = false`) : un compte désactivé ne peut plus se connecter même avec le bon PIN.

## 5. Chiffrement des données locales (à prévoir)

- Le paquet `flutter_secure_storage` (9.2.2) est **déjà intégré** au `pubspec.yaml` : il servira aux secrets (jetons JWT de la phase serveur, clé de chiffrement de base).
- Chiffrement SQLCipher de la base : extension ultérieure (`NativeDatabase` accepte un executeur chiffré), à coupler avec une migration de première ouverture. Ne pas l'improviser sans plan de migration (voir 02-donnees-et-migrations.md).
- Les sauvegardes JSON (`BackupService.exportToJson`) contiennent toutes les tables : les traiter comme des données sensibles (stockage local uniquement, partage ciblé, suppression après usage).

## 6. Journal d'activité

Toutes les opérations sensibles sont tracées dans `activity_log` (utilisateur, action, entité, entityId, détails, horodatage) via `ActivityLogger` — l'utilisateur courant est lu depuis la session, sinon « système ». Actions couvertes (`ActivityAction`) : création, modification, suppression, paiement, validation, changement de statut, changement de tarif, modification de workflow, exception autorisée, transfert PC, synchronisation, connexion/déconnexion. Consultation : `/settings/journal` (admin).

## 7. Recommandations de production

1. **Changer immédiatement les PIN de démo** (Admin/1234, Faniry/1111) et imposer un PIN à 6 chiffres minimum aux comptes réels.
2. **Sauvegarder régulièrement** : export JSON avant toute migration de schéma ou restauration ; conserver un exemplaire hors du téléphone.
3. **HTTPS obligatoire** dès que le serveur quitte le LAN (phase 2 du déploiement, voir 05-backend-nestjs.md) ; sur LAN, URL saisie par l'admin uniquement.
4. Ne jamais embarquer d'URL serveur ni de secret dans le dépôt : tout est saisi à l'exécution (`settings`) ou stocké via `flutter_secure_storage`.
5. Restreindre la purge (`canPurgeTrash`) et la restauration (`canImportBackup`) aux admins — déjà le cas — et former les opérateurs : la corbeille est réversible, la purge non.
6. Vérifier périodiquement le journal (`/settings/journal`) : connexions inattendues, exceptions autorisées trop fréquentes.

## 8. Synthèse des protections en place

| Risque | Protection |
|---|---|
| Vol du téléphone, lecture des PIN | PIN haché SHA-256 salé, jamais stocké en clair. |
| Session résiduelle après emprunt | Session en mémoire : déconnexion à l'arrêt de l'app, redirect `/login`. |
| Opérateur modifiant tarifs/modules/utilisateurs | `AppPermissions` + redirect `/settings/*` réservé admin. |
| Contournement de règle métier | Exception autorisée tracée (raison, utilisateur, date, journal). |
| Effacement accidentel | Suppression douce + corbeille ; purge admin doublement confirmée. |
| Écrasement de données en sync | Conflits posés dans `sync_conflicts`, résolution admin, jamais silencieuse. |
| Envoi de données sans consentement | `SyncEngine.run` : aucun appel réseau sans `server_url` configurée. |
| Perte du téléphone | Sauvegarde JSON exportable ; re-import admin sur l'appareil de remplacement. |
