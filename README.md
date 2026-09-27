# MSN Manager

Application Flutter mobile de gestion de Multi-Services Numériques (MSN), migrée du prototype V19.

## Fonctionnalités
- Authentification locale et session persistante
- Dashboard dynamique
- Réception client en 4 étapes
- Clients et historique lié
- Commandes et filtres
- Workflow métier par service
- Boucle présentation → validation/corrections
- Paiement vérifié avant livraison
- Livraison et suivi
- Devis et factures
- Tâches
- Notifications
- Services & tarifs
- Portfolio
- Documents
- Administration et paramètres
- Export JSON des données
- Réinitialisation avec confirmation
- Persistance locale hors ligne

## Sécurité
- Aucun mot de passe de démonstration n'est affiché dans l'interface.
- Les mots de passe sont stockés sous forme de hash SHA-256 dans les données initiales.
- Chaque utilisateur peut modifier son mot de passe depuis Paramètres.

## Synchronisation
- Base locale persistante hors ligne.
- Synchronisation en ligne via une URL REST configurable.
- Détection Bluetooth LE des appareils compatibles pour la liaison locale.
- Le logiciel PC doit exposer le protocole de synchronisation MSN défini par l’API/serveur ou un service BLE compatible.

## Lancement
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Codemagic
Le fichier `codemagic.yaml` configure analyse, tests, APK et AAB. Pour une signature Play Store, renseigner les variables/secrets de signature dans Codemagic.

## Source fonctionnelle
Le prototype HTML V19 fourni dans la conversation reste inclus à titre de référence dans `reference/`.
