import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Signature release (facultative).
// Deux sources possibles, la première trouvée gagne :
//   1. Variables d'environnement Codemagic (CM_KEYSTORE_PATH, etc.) —
//      renseignées via la section « Code signing » du workflow ou un groupe
//      de variables chiffrées.
//   2. Fichier android/key.properties (hors dépôt, voir .gitignore).
// Si aucune n'est fournie, l'APK release est signé avec la clé debug :
// il s'installe et fonctionne, mais n'est pas destiné au Play Store.
// ---------------------------------------------------------------------------
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val cmKeystorePath = System.getenv("CM_KEYSTORE_PATH")
val keystoreAvailable = cmKeystorePath != null || keystoreProperties.isNotEmpty()

android {
    namespace = "mg.msn.msn_manager_mobile"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Requis par flutter_local_notifications (java.time sur anciens Android)
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "mg.msn.msn_manager_mobile"
        // Vous pouvez ajuster ces valeurs selon vos besoins :
        // https://flutter.dev/to/review-gradle-config
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (keystoreAvailable) {
        signingConfigs {
            create("releaseKeystore") {
                if (cmKeystorePath != null) {
                    storeFile = file(cmKeystorePath)
                    storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                    keyAlias = System.getenv("CM_KEY_ALIAS")
                    keyPassword = System.getenv("CM_KEY_PASSWORD")
                } else {
                    storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                    storePassword = keystoreProperties["storePassword"] as String?
                    keyAlias = keystoreProperties["keyAlias"] as String?
                    keyPassword = keystoreProperties["keyPassword"] as String?
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystoreAvailable) {
                signingConfigs.getByName("releaseKeystore")
            } else {
                // Fallback : signature debug (tests internes, installation directe)
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
