# 10 — Générer l'APK Android

Le dépôt contient le code Dart/Flutter (pas de dossier `android/` versionné) : il est régénéré localement avec `flutter create`. Cible : Android, application `msn_manager_mobile`, organisation `mg.msn`.

## 1. Régénérer la plateforme Android

À la racine du projet (`download/msn-manager-mobile/`) :

```bash
flutter create --org mg.msn --project-name msn_manager_mobile --platforms android .
```

`--org mg.msn` fixe l'identifiant applicatif `mg.msn.msn_manager_mobile`. Ne pas oublier le `.` final (dossier courant).

## 2. Dépendances et code généré

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Le second commande génère `lib/core/database/app_database.g.dart` (dataclasses Drift : `Client`, `OrdersCompanion`, …). Il est indispensable avant toute compilation ; à relancer après chaque modification de `tables.dart`.

## 3. AndroidManifest.xml

Fichier : `android/app/src/main/AndroidManifest.xml`. Ajouter dans `<manifest>` (hors `<application>`) et déclarer les récepteurs de `flutter_local_notifications` 17 (planification des rappels) :

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Réseau : client REST de synchronisation (http/https). -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <!-- Notifications : Android 13+ exige une permission runtime. -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <!-- Rappels planifiés précis (deadlines, relances). -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

    <!-- Re-programmer les rappels après redémarrage du téléphone. -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

    <application android:label="MSN Manager" android:name="${applicationName}"
                 android:icon="@mipmap/ic_launcher">
        <!-- … flutter activity déjà générée par flutter create … -->

        <!-- Récepteurs flutter_local_notifications : rappels planifiés
             et re-planification au boot / mise à jour du paquet. -->
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

Notes :
- `POST_NOTIFICATIONS` est demandée au runtime sur Android 13+ (API 33) ; sur 12 et moins elle est ignorée. La demande de permission se fait au premier lancement (démarrage contrôlé de `app.dart`).
- `SCHEDULE_EXACT_ALARM` permet le mode `zonedSchedule` précis ; l'app reste tolérante (`AndroidScheduleMode.inexactAllowWhileIdle` utilisé par `NotificationService`) si l'alarme exacte est refusée.
- La permission `INTERNET` ne rend pas l'app dépendante du réseau : elle n'est utilisée que par le moteur de sync optionnel.
- Si l'URL du serveur reste en `http://` sur LAN, ajouter `android:usesCleartextTraffic="true"` sur `<application>` (à retirer dès le passage en HTTPS).

## 4. Compiler

```bash
# Debug (tests sur appareil)
flutter build apk --debug

# Release (distribution)
flutter build apk --release
```

Artefact : `build/app/outputs/flutter-apk/app-release.apk`. Pour séparer les ABI (APK plus légers) : `flutter build apk --release --split-per-abi` (produit `app-arm64-v8a-release.apk` etc.). Pour un bundle Play Store : `flutter build appbundle --release`.

## 5. Signer la version release

Créer le keystore une seule fois :

```bash
keytool -genkey -v -keystore ~/msn-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias msn
```

Référencer le keystore dans `android/key.properties` (hors dépôt) :

```properties
storePassword=********
keyPassword=********
keyAlias=msn
storeFile=/home/<user>/msn-release-key.jks
```

Puis dans `android/app/build.gradle` :

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

Relancer `flutter build apk --release` : l'APK est signé. Conserver le keystore et ses mots de passe en lieu sûr (réinstallation des mises à jour impossible sans lui).

## 6. Installer sur un appareil

```bash
adb devices                     # l'appareil doit apparaître (débogage USB activé)
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Alternatives : `flutter install`, ou copie directe de l'APK sur le téléphone (installation « sources inconnues ») — pratique pour le terrain sans magasin d'applications.

## 7. Vérifications post-installation

1. Premier lancement : écran Splash -> Login (comptes démo Admin/1234, Faniry/1111), base seedée (`demo_seeded`).
2. Créer un client : la ligne apparaît dans `sync_queue` (écran `/sync`, mode SERVEUR NON CONFIGURÉ tant qu'aucune URL n'est saisie).
3. Planifier un rappel et vérifier la notification (canal « Rappels MSN »).
4. Générer un PDF (fiche service) et le partager.
