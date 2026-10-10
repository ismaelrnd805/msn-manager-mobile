# 8. Compilation continue avec Codemagic

Ce projet est préparé pour **Codemagic** (https://codemagic.io), service CI/CD
spécialisé Flutter capable de compiler **Android (APK)** et **Windows (exe)**
sur des machines distinctes. La configuration est entièrement décrite dans
`codemagic.yaml` à la racine du dépôt — aucune action manuelle dans l'interface
n'est requise en dehors du premier branchement et des variables de signature.

## 8.1 Dossiers de plateforme : android/ inclus, windows/ généré en CI

**`apps/mobile/android/` est INCLUS dans le dépôt.** Il a été généré par
`flutter create --platforms=android --org mg.msn --project-name msn_mobile`
(Flutter 3.35.4, Gradle 8.12, AGP 8.9.1, compileSdk API 36) puis validé par un
build réel interrompu volontairement à la demande — la configuration Gradle,
la résolution des 55 dépendances et la chaîne Dart AOT sont donc **éprouvées**.
Le patch `scripts/ci/patch_android.py` a appliqué les deux réglages que le
template ne contient pas : la permission **INTERNET** (indispensable à la
synchronisation, absente du template en release) et le libellé applicatif
**« MSN Manager »**. Le script `scripts/ci/android_prepare.sh` détecte la
présence du dossier et ne régénère pas — il se contente de `pub get` + patch
idempotent.

**`apps/desktop/windows/` n'est PAS dans le dépôt** : Flutter ne compile le
desktop Windows QUE sur Windows (outillage C++/Visual Studio) — il ne peut pas
être généré depuis Linux. Le workflow Codemagic `windows-desktop` l'exécute
avec `flutter create . --platforms=windows --project-name msn_desktop` sur la
machine Windows de la CI, garantissant des runners alignés sur le SDK utilisé.

Réglages Gradle embarqués (gradle.properties) : heap limité à 1536 Mo et
daemon désactivé — valeurs adaptées aux petites machines CI ; augmentez
`-Xmx` si votre serveur de build est généreux en RAM.

## 8.2 Branchement du dépôt

1. Créez un dépôt Git (GitHub, Bitbucket ou GitLab) et poussez le contenu de
   `msn-manager/` (avec `vendor/` ou sans — Codemagic exécute
   `composer install` côté serveur uniquement en local, pas en CI).
2. Sur Codemagic : **Add application** → sélectionnez le dépôt.
3. Choisissez **« Specify .yaml file name »** → `codemagic.yaml`.
   Les deux workflows apparaissent : `android-mobile` et `windows-desktop`.

> Les scripts du workflow Windows s'exécutent en **PowerShell** sur les
> machines Windows de Codemagic — c'est déjà pris en compte dans le YAML.

## 8.3 Workflow `android-mobile` (machine macOS)

Déroulement automatique :

1. `dart test` dans `packages/core` (36 tests — le build **échoue** si le
   cœur n'est pas vert, garde-fou voulu).
2. `flutter create` + patch manifeste (`scripts/ci/android_prepare.sh`).
3. `flutter build apk --release` dans `apps/mobile`.
4. Signature : `scripts/ci/android_sign.sh`.
5. Artefact récupérable : `apps/mobile/build/app/outputs/flutter-apk/*.apk`.

### Signature debug (par défaut, sans configuration)

Sans aucune variable, l'APK release est signé avec la clé debug : installable
sur un téléphone pour les tests internes. Ne pas publier cet APK sur le Play
Store.

### Signature production (recommandée pour diffusion)

Générez un keystore UNE fois, sur votre machine (jamais commité) :

```bash
keytool -genkeypair -v -keystore msn-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias msn
```

Dans Codemagic → votre app → **Environment variables** → créez le groupe
**`msn_android_signing`** (marqué *secure*) avec :

| Variable | Valeur |
|---|---|
| `CM_KEYSTORE_PATH` | chemin du keystore téléversé (voir *Code signing* → Android → upload du fichier) |
| `CM_KEYSTORE_PASSWORD` | mot de passe du keystore |
| `CM_KEY_ALIAS` | `msn` |
| `CM_KEY_ALIAS_PASSWORD` | mot de passe de la clé |

Le script re-signe l'APK avec `zipalign` + `apksigner` puis vérifie la
signature. En cas d'échec, le build est marqué rouge (aucun APK invalide
n'est publié).

## 8.4 Workflow `windows-desktop` (machine Windows)

Déroulement automatique :

1. `flutter create --platforms=windows` si `windows/` absent
   (`apps/desktop`).
2. `flutter build windows --release`.
3. Empaquetage : `Compress-Archive` de tout le dossier `Release/`
   (exe + DLL + données) vers `apps/desktop/dist/MSN_Manager_Windows.zip`.
4. Artefact récupérable : `apps/desktop/dist/*.zip`.

Le ZIP s'installe par simple décompression : `msn_desktop.exe` + DLL vont
ensemble. Prérequis client : Windows 10/11 64 bits (Visual C++ redistribuable
inclus par les DLL embarquées de Flutter).

## 8.5 Notifications

Les deux workflows envoient un e-mail aux destinataires listés dans
`publishing.email.recipients` (succès ET échec). Remplacez
`vous@votre-domaine.mg` dans `codemagic.yaml` par l'adresse réelle.

## 8.6 Coûts et déclenchement

- Chaque workflow consigne des minutes sur son type de machine (macOS pour
  Android, Windows pour le desktop). Le quota gratuit mensuel de Codemagic
  suffit largement pour des builds hebdomadaires de ce projet.
- Déclenchement manuel : **Start new build** → choisir le workflow.
- Déclenchement automatique : ajoutez à un workflow, si souhaité :

```yaml
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: main
```

## 8.7 Dépannage CI

| Symptôme | Cause probable | Correctif |
|---|---|---|
| `flutter create` échoue | pubspec corrompu ou nom incohérent | vérifier `name:` (`msn_mobile` / `msn_desktop`) et `--project-name` identiques |
| `dart test` rouge sur CI mais vert en local | dépendances résolues différemment | committer `packages/core/pubspec.lock` (déjà fait) |
| APK non installable | APK signé debug + Play Protect | pour diffusion : configurer le groupe `msn_android_signing` |
| `apksigner: command not found` | `ANDROID_HOME` absent sur l'image | les images Codemagic la définissent ; sinon vérifier le workflow |
| Build Windows : erreur C++ | SDK Windows / VS incomplet sur l'instance | relancer (images Codemagic incluent VS 2022) ; vérifier `instance_type: windows_x2` |
| ZIP Windows vide | chemin Release différent | vérifier `build/windows/x64/runner/Release/` après le build |
| `window_size` introuvable | accès GitHub bloqué | le paquet vient d'un dépôt Git public ; vérifier la sortie `pub get` |

## 8.8 Ce qui a été réellement vérifié (honnêteté de livraison)

- `codemagic.yaml` suit le schéma documenté de Codemagic (workflows,
  `instance_type`, `environment.flutter`, scripts, `artifacts`, `publishing`).
- Les scripts `android_prepare.sh`, `patch_android.py` (exécuté localement
  après génération de manifeste de référence), `android_sign.sh` ont été
  relus et testés unitairement dans la mesure du possible **ici**.
- **Aucun build Codemagic n'a été exécuté depuis cet environnement** : la
  première compilation réelle se fera sur Codemagic après branchement du
  dépôt. Toute évolution du schéma Codemagic après cette date devra être
  reprise dans `codemagic.yaml`.
