# Dépannage

## Serveur

### `Class "config" does not exist` après une opération Composer

**Symptôme** : le premier `artisan package:discover` lancé par Composer échoue,
le second réussit.
**Cause** : combinaison PHP portable / hook post-autoload (constaté dans cet
environnement de développement).
**Contournement** : relancer `php artisan package:discover` une fois ; ne pas
enchaîner d'opérations Composer sur un serveur en charge.

### `429 LIMITE_DEBIT`

Limites volontaires : login 5/min/IP, sync 30/min, métier 240/min. Attendre la
fenêtre d'une minute ou ajuster `AppServiceProvider::boot()`.

### Migrations : `boolean = integer` sur PostgreSQL

Corrigé dans les migrations : les CHECK booléens utilisent `IN (TRUE,FALSE)`,
valide sur PostgreSQL **et** SQLite.

### Erreur `VERSION_CONFLICT` sur un PATCH

Normal : le serveur exige la version courante (`version` du record). Relisez la
ressource puis réessayez avec `expected_version` correct — c'est le mécanisme
anti-écrasement exigé par la spécification.

## Application Flutter

### « libsqlite3.so.0 introuvable » (tests du cœur sur Linux)

```bash
export MSN_SQLITE_LIB=/chemin/vers/libsqlite3.so.0
```

### L'app redémarre et ne trouve pas ses données

La base locale vit à l'emplacement configuré (`db_chemin` dans
SharedPreferences). Ne changez pas le chemin entre deux lancements.

### Conflits affichés en attente

Ouvrez l'écran Paramètres → l'état de synchronisation liste les conflits
`a_resoudre`. Choisissez la version à conserver ou fusionnez — la résolution est
poussée comme nouvelle opération auditable. Aucune donnée n'est écrasée
automatiquement.

## Build Android

### `flutter build apk` échoue avec minSdkVersion

Le paquet `file_picker` exige minSdk 21+. Dans `android/app/build.gradle` :
`minSdk = 21` (déjà requis par Flutter 3.24 par défaut).

### Signature release

Créez un keystore dédié (`keytool -genkey -v -keystore msn.jks`) et configurez
`android/key.properties` — **ne committez jamais le keystore**.

## Build Windows

- Visual Studio 2022 avec charge « Développement Desktop en C++ » obligatoire ;
- premier build long (CMake) : 5-15 min ;
- l'exécutable se trouve dans `build/windows/x64/runner/Release/`.

## Synchronisation

### Les opérations restent « en attente »

- vérifiez l'URL du serveur dans Paramètres ;
- connectez-vous (jeton requis) ;
- l'état affiche la dernière erreur — réseau ou 401 = se reconnecter.

### Un appareil « fantôme » reste listé

`DELETE /devices/{id}` depuis un appareil connecté, ou révoquez côté serveur
(table `appareils`, `actif=false`).
