# msn_desktop — MSN Manager V1 (Windows)

Application Windows de MSN Manager V1 (un compte appareil Windows, spéc. §3).
Toute la logique vit dans `packages/core` (Dart pur) et l'interface partagée
dans `packages/msn_ui` — ce paquet n'est qu'un point d'entrée mince avec
dimensionnement de fenêtre (`window_size`).

Le dossier `windows/` n'est PAS versionné : Flutter ne génère ni ne compile
le runner Windows que **sur Windows** (Visual Studio 2022 « Développement
Desktop en C++ » requis).

```powershell
flutter create . --platforms=windows --project-name msn_desktop
flutter pub get
flutter run -d windows
flutter build windows --release
# Livrable : ZIP du dossier build\windows\x64\runner\Release\ (exe + DLL)
# scripts\build_windows.ps1 automatise tout ce qui précède.
```

CI Codemagic : workflow `windows-desktop` — génère `windows/`, compile et
produit `dist/MSN_Manager_Windows.zip` (voir `codemagic.yaml` à la racine et
`docs/08-codemagic.md`).
