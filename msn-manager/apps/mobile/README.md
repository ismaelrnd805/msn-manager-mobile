# msn_mobile — MSN Manager V1 (Android)

Application Android de MSN Manager V1 (un compte appareil Android, spéc. §3).
Toute la logique vit dans `packages/core` (Dart pur) et l'interface partagée
dans `packages/msn_ui` — ce paquet n'est qu'un point d'entrée mince.

Le dossier `android/` est **inclus et déjà patché** (permission INTERNET,
libellé « MSN Manager », applicationId `mg.msn.msn_mobile`) : inutile de
relancer `flutter create`.

```bash
flutter pub get
flutter run -d <id-appareil>     # développement
flutter build apk --release      # APK : build/app/outputs/flutter-apk/
```

CI Codemagic : workflow `android-mobile` (voir `codemagic.yaml` à la racine et
`docs/08-codemagic.md`). Test de fumée : `flutter test`.
